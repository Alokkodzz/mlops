output "VPC_ID" {
    description = "My infra VPC ID"
    value = aws_vpc.TF_VPC.id
}

output "private_subnet_ids" {
    description = "List of private subnet IDs"
    value = aws_subnet.TF_subnet_private[*].id
  
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.TF_VPC.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.TF_subnet_public[*].id
}