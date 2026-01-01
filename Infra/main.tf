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
  subnet_ids = module.vpc.public_subnet
  subnet_id = local.subnet_id
  availability_zone = local.VPC_availability_zone
}

module "mlops" {
  source = "./modules/mlops"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ami = local.ami
  instance_type = local.instance_type
  launch_template_user_data = local.launch_template_user_data
}
