###############
## EKS ROLE ##
###############

resource "aws_iam_role" "eks_role" {
    name = "SicrediEksRole"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": "AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "eks_policy" {
  name        = "SicrediEksRolePolicy"
  path        = "/"
  description = "Provides full permissions to S3 buckets"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [        
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}