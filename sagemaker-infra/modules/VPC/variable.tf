variable "private_subnet" {
  description = "CIDR block for Private subnet"
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "public_subnet" {
  description = "CIDR block for Public subnet"
  type = list(string)
  default = [ "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24" ]
}

variable "tags" {
  description = "Tag for this project"
  type        = map(string)
  default = {
    "Name" = "mlops"
    "Environment"  = "Dev"
  }
}

variable "availability_zone" {
    description = "AZ for VPC"
    type = list(string)
}

