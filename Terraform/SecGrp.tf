# creates the security groups

# the security group for the instance
resource "aws_security_group" "checkpoint-sg" {
  name        = "checkpoint-sg"
  description = "checkpoint-sg"
  tags = {
    Name = "checkpoint-sg"
  }
}

# allows ssh from anywhere to the instance - look at readme's additional notes 3 for additional explanation
resource "aws_vpc_security_group_ingress_rule" "sshfrommyIP" {
  security_group_id = aws_security_group.checkpoint-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# allows http from anywhere to the instance - look at readme's additional notes 2 for additional explanation
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.checkpoint-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# allows traffic to the outside
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.checkpoint-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.checkpoint-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# the LB security group
resource "aws_security_group" "checkpoint-lb-sg" {
  name        = "checkpoint-lb-sg"
  description = "checkpoint-lb-sg"
  tags = {
    Name = "checkpoint-lb-sg"
  }
}

# allow both directions but only on port 80 in the LB

resource "aws_vpc_security_group_ingress_rule" "allow_lb_http_ipv4" {
  security_group_id = aws_security_group.checkpoint-lb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_lb_http_ipv6" {
  security_group_id = aws_security_group.checkpoint-lb-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_lb_http_ipv6_out" {
  security_group_id = aws_security_group.checkpoint-lb-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_lb_http_ipv4_out" {
  security_group_id = aws_security_group.checkpoint-lb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}