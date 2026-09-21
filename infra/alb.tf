resource "aws_lb" "alb" {
  name               = "${local.tag_header}alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${local.tag_header}alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${local.tag_header}web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.tag_header}web-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ASG <-> ALB 타겟 그룹 연결 (asg.tf 의 ASG 블록은 수정하지 않기 위해 attachment 리소스 사용)
resource "aws_autoscaling_attachment" "asg_web" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.web.arn
}
