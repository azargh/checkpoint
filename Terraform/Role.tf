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

resource "aws_iam_instance_profile" "ec2-s3-instance-profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.S3Role.name
}

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
    }
  ]
}
EOF
}