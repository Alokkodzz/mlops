variable "ami" {
    description = "AMI ID for EC2 Instance"
    type = string
}

variable "instance_type" {
    description = "Instance type for EU2 Instacne"
    type = string
  
}

variable "vpc_id" {
  description = "The VPC ID to use for ASG and ALB"
  type        = string
}


variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}
