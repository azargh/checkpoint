resource "aws_lb" "CheckPoint-lb" {
  name               = "CheckPoint-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.checkpoint-lb-sg.id]
  subnets            = [aws_default_subnet.subnet-us-east-1a.id, aws_default_subnet.subnet-us-east-1b.id, aws_default_subnet.subnet-us-east-1c.id]
  enable_deletion_protection = true
}

resource "aws_default_subnet" "subnet-us-east-1a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "subnet-us-east-1b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "subnet-us-east-1c" {
  availability_zone = "us-east-1c"
}

resource "aws_lb_target_group" "CheckPoint-target-group" {
  name = "CheckPoint-target-group"
  port = "5000"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_default_vpc.default-vpc.id
}

resource "aws_default_vpc" "default-vpc" {
}

resource "aws_alb_target_group_attachment" "CheckPoint-target-group-attachment" {
  target_group_arn = aws_lb_target_group.CheckPoint-target-group.arn
  target_id = aws_instance.CheckPoint.id
  depends_on = [aws_lb.CheckPoint-lb]
}

resource "aws_lb_listener" "CheckPoint-Listener" {
  load_balancer_arn = aws_lb.CheckPoint-lb.arn
  port = "80"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.CheckPoint-target-group.arn
  }
  depends_on = [aws_lb.CheckPoint-lb]
}