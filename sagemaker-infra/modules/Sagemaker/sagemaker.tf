resource "aws_iam_role" "sagemakerdomainexecutionrole" {
  name = "SageMakerDomainExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_domain_execution_role_attach_sagemaker" {
  role       = aws_iam_role.sagemakerdomainexecutionrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_domain_execution_role_attach_s3" {
  role       = aws_iam_role.sagemakerdomainexecutionrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_sagemaker_domain" "mlops_sagemaker_domain" {
  domain_name = "MLOPS"
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids = var.subnet_ids
  app_network_access_type = "VpcOnly"


  default_user_settings {
    execution_role = aws_iam_role.sagemakerdomainexecutionrole.arn
  }
}

resource "aws_sagemaker_user_profile" "aws_sagemaker_user_profile" {
  domain_id         = aws_sagemaker_domain.mlops_sagemaker_domain.id
  user_profile_name = "OpsTeam"

  tags = {
    studiouserid = "ops123"
  }
}

resource "aws_sagemaker_user_profile" "aws_sagemaker_user_profile_alok" {
  domain_id         = aws_sagemaker_domain.mlops_sagemaker_domain.id
  user_profile_name = "Alok"

  tags = {
    studiouserid = "alok123"
  }
}

resource "aws_iam_user" "sagemakeropsuser" {
  name = "SagemakerOpsUser"

  tags = {
    studiouserid = "ops123"
  }
}

resource "aws_iam_policy" "sagemaker_ops_user_policy" {
  name        = "SagemakerOpsUserPolicy"
  description = "Allow Sagemaker Ops User to access SageMaker Domain and User Profile"

  policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "AllowConsoleListAndDescribe"
                Effect = "Allow"
                Action = [
                    "sagemaker:ListDomains",
                    "sagemaker:ListUserProfiles",
                    "sagemaker:ListApps",
                    "sagemaker:DescribeDomain",
                    "sagemaker:DescribeUserProfile",
                    "sagemaker:ListTags"
                ]
                Resource = "*"
            },
            {
                Sid    = "AllowAccessToSpecificDomainAndUserProfile"
                Effect = "Allow"
                Action = [
                    "sagemaker:CreatePresignedDomainUrl"
                ]
                Resource = "*"
                Condition = {
                    StringEquals = {
                        "sagemaker:ResourceTag/studiouserid" = "$${aws:PrincipalTag/studiouserid}"
                    }
                }
            },
            {
              "Sid": "AllowIamReadForConsole",
              "Effect": "Allow",
              "Action": [
                "iam:GetRole",
                "iam:ListRoles",
                "iam:PassRole"
              ],
              "Resource": "*"
            }]
  }) 
  
}

resource "aws_iam_user_policy_attachment" "sagemaker_ops_user_policy_attach" {
  user       = aws_iam_user.sagemakeropsuser.name
  policy_arn = aws_iam_policy.sagemaker_ops_user_policy.arn
}