resource "aws_instance" "CheckPointJenkins" {
  ami                    = data.aws_ami.amiID.id
  instance_type          = "t2.micro"
  key_name               = "checkpoint-key"
  security_groups = ["checkpoint-sg"]
  availability_zone      = "us-east-1a"
  tags = {
    Name = "CheckPointJenkins"
  }
}