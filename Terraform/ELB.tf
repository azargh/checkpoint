# Contains the code for the load balancer

resource "aws_lb" "CheckPoint-lb" {
  name               = "CheckPoint-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.checkpoint-lb-sg.id]
  subnets            = [aws_default_subnet.subnet-us-east-1a.id, aws_default_subnet.subnet-us-east-1b.id, aws_default_subnet.subnet-us-east-1c.id]
}

# default subnets for use with the load balancer
resource "aws_default_subnet" "subnet-us-east-1a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "subnet-us-east-1b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "subnet-us-east-1c" {
  availability_zone = "us-east-1c"
}

# creates a target group to attach to the load balancer
resource "aws_lb_target_group" "CheckPoint-target-group" {
  name = "CheckPoint-target-group"
  port = "80"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_default_vpc.default-vpc.id
}

resource "aws_default_vpc" "default-vpc" {
}

# attaches the target group made above to the load balancer
resource "aws_alb_target_group_attachment" "CheckPoint-target-group-attachment" {
  target_group_arn = aws_lb_target_group.CheckPoint-target-group.arn
  target_id = aws_instance.CheckPoint.id
  port = 80
  depends_on = [aws_lb.CheckPoint-lb]
}

# creates the listener that will listen on the load balancer and forward the requests
# we only forward http requests on port 80 to the target group we created above
resource "aws_lb_listener" "CheckPoint-Listener" {
  load_balancer_arn = aws_lb.CheckPoint-lb.arn
  protocol = "HTTP"
  port = "80"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.CheckPoint-target-group.arn
  }
  depends_on = [aws_lb.CheckPoint-lb]
}

# creates the file that holds the load balancer's dns name for ease of use
resource local_file "lb-dns-name" {
  content = aws_lb.CheckPoint-lb.dns_name
  filename = "lb-dns-name.txt"
}