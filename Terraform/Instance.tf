resource "aws_instance" "CheckPoint" {
  ami                    = data.aws_ami.amiID.id
  instance_type          = "t2.micro"
  key_name               = "checkpoint-key"
  vpc_security_group_ids = [aws_security_group.checkpoint-sg.id]
  availability_zone      = "us-east-1a"
  tags = {
    Name = "CheckPoint"
  }
  iam_instance_profile = aws_iam_instance_profile.ec2-s3-instance-profile.name
}