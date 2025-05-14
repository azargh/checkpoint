# this script is responsible for creating roles

# creates a role that allows EC2 to access S3
resource "aws_iam_role" "S3Role" {
  name = "CheckPoint-IAM-Role-EC2-to-S3"
  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# also a part of the additional notes (1)
resource "aws_iam_role" "GitHubActionsRole" {
  name = "GitHubActionsRole"
  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.github_openid_connect_provider.arn}"
      },
      "Sid": "",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:azargh/checkpoint:*"
          }
      }
    }
  ]
}
EOF
}

# creates an instance profile with the role we made above
resource "aws_iam_instance_profile" "ec2-s3-instance-profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.S3Role.name
}

# creates a role policy that allows EC2 to access SSM, S3 and SQS
resource "aws_iam_role_policy" "ec2-s3-role-policy" {
  name = "ec2-s3-role-policy"
  role = aws_iam_role.S3Role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ssm:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}