output "EC2_role" {
  description = "EC2 IAM role"
  value       = aws_iam_role.ec2_s3_eks_access_role.arn
}