resource "aws_alb" "main" {
  name               = "cb-load-balancer"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]
  load_balancer_type = "application"
}

resource "aws_alb_target_group" "market_data" {
  name        = "market-data-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "market_data_listener" {
  load_balancer_arn = aws_alb.main.id
  port              = 8081
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.market_data.id
    type             = "forward"
  }
}