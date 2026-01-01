terraform {
  backend "s3" {
    bucket = "alokk-mlops"
    key    = "State/terraform.tfstate"
    region = "us-east-1"
  }
}
