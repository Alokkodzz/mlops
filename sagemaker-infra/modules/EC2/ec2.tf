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

resource "aws_iam_role" "ec2_s3_eks_access_role" {
  name = "EC2S3EKSAccessRole"

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

resource "aws_iam_policy" "ec2_eks_s3_access_policy" {
  name        = "EC2S3EKSFullAccessPolicy"
  description = "Allow EC2 instances to access all S3 buckets and EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "eks:*",
        "iam:ListOpenIDConnectProviders",
        "iam:GetOpenIDConnectProvider",
        "iam:CreateOpenIDConnectProvider",
        "iam:PassRole",
        "iam:TagOpenIDConnectProvider",
        "iam:CreatePolicy",
        "cloudformation:ListStacks",
        "cloudformation:CreateStack",
        "cloudformation:DeleteStack",
        "cloudformation:DescribeStacks"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_eks_access_attach" {
  role       = aws_iam_role.ec2_s3_eks_access_role.name
  policy_arn = aws_iam_policy.ec2_eks_s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2S3EKSAccessInstanceProfile"
  role = aws_iam_role.ec2_s3_eks_access_role.name
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
}

resource "aws_instance" "ec2_from_lt" {
  launch_template {
    id      = aws_launch_template.mlops_template.id
    version = "$Latest"
  }
  subnet_id = var.public_subnet_ids[0]

  tags  = {
    Name = "MLOPS-EC2-Test_Instance"
  }
}
