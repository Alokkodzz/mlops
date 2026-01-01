locals {
  ami            = "ami-0345f44fe05216fc4" #2022 win server AMI
  instance_type  = "t2.micro"
  subnet_id      = "subnet-0802eb25e45a54f45"
  VPC_availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]


  launch_template_user_data = templatefile(
    "${path.module}/userdata.sh",
    {}
  )

}