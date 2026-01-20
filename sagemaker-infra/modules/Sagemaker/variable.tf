variable "vpc_id" {
    description = "VPC ID for sagemaker"
    type = string
}

variable "subnet_ids" {
    description = "Security Group ID for sagemaker"
    type = list(string)
}