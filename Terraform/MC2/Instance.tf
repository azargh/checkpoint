resource "aws_instance" "CheckPointMC2" {
  ami                    = data.aws_ami.amiID.id
  instance_type          = "t2.micro"
  key_name               = "checkpoint-key"
  vpc_security_group_ids = [aws_security_group.checkpoint-sg.id]
  availability_zone      = "us-east-1a"
  tags = {
    Name = "CheckPointMC2"
  }
}