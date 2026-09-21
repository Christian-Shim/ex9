# ALB 보안그룹: 인터넷에서 HTTP 허용
resource "aws_security_group" "alb" {
  name        = "${local.tag_header}external-alb-sg"
  description = "External ALB - allow HTTP from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_header}external-alb-sg"
  }
}

# SSH 보안그룹
resource "aws_security_group" "ssh" {
  name        = "${local.tag_header}ssh-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_header}ssh-sg"
  }
}

# 웹 인스턴스 보안그룹: ALB 에서 오는 HTTP 만 허용
resource "aws_security_group" "web" {
  name        = "${local.tag_header}web-sg"
  description = "Web instances - allow HTTP from ALB only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_header}web-sg"
  }
}
