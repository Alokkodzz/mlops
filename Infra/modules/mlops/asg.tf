resource "aws_security_group" "mlops_sg" {
  name_prefix = "mlops-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP for security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "EC2S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "EC2S3FullAccessPolicy"
  description = "Allow EC2 instances to access all S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_attach" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2S3AccessInstanceProfile"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_launch_template" "mlops_template" {
  name_prefix   = "mlops-template"
  image_id      = var.ami # Windows Server AMI
  instance_type = var.instance_type
  key_name      = "mlops"
  vpc_security_group_ids = [aws_security_group.mlops_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = base64encode(var.launch_template_user_data)
}


resource "aws_autoscaling_group" "mlops_asg" {
  name  = "mlops-batch"
  desired_capacity     = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.mlops_template.id
    version = "$Latest"
  }

  termination_policies = ["OldestInstance"]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 0
      min_healthy_percentage = 25
      }
  }

  tag {
    key                 = "version"
    value               = "v1.0.0"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "mlops-batch"
    propagate_at_launch = true
  }
}

resource "aws_lb" "mlops_alb" {
  name               = "mlops-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mlops_sg.id]
  subnets            = var.public_subnet_ids


  tags = {
    Environment = "mlops"
  }
}

resource "aws_lb_target_group" "mlops_alb_target_group" {
  name     = "mlops-alb-target-group"
  port     = 6000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"  # Or a dedicated health endpoint
    port                = "traffic-port" # Uses the same port (5002)
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"  # Success HTTP codes
  }
}

resource "aws_autoscaling_attachment" "mlops_attachment" {
  autoscaling_group_name = aws_autoscaling_group.mlops_asg.id
  lb_target_group_arn    = aws_lb_target_group.mlops_alb_target_group.arn
}

resource "aws_lb_listener" "http_listener_mlops" {
  load_balancer_arn = aws_lb.mlops_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlops_alb_target_group.arn
  }
}
