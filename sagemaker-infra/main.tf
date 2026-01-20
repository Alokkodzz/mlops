terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.87.0"
    }
  }
}


provider "aws"{
    region = "us-east-1"
}

module "vpc" {
  source = "./modules/VPC"
  availability_zone = local.VPC_availability_zone
}

module "ec2" {
  source = "./modules/EC2"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ami = local.ami
  instance_type = local.instance_type
}

module "sagemaker" {
  source = "./modules/Sagemaker"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}