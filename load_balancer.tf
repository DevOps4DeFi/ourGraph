
resource "aws_lb_target_group" "graphnode-graphql" {
  name     = "graphnode-graphql"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  tags = {
    name = "graphql"
  }
  health_check { ##TODO figure out a better healthcheck maybe getting data from the monitoring/management ports
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 8000
  }
}

## TODO ports 8020[JSON-RPC admin], 8030[IndexNode], 8040[Metrics] may need to be exposed to the internet
## If so they need their own target groups.
resource "aws_lb_listener_rule" "graphnode-graphql" {
  listener_arn = var.lb_https_listener_arn
  action {
    target_group_arn = aws_lb_target_group.graphnode-graphql.arn
    type = "forward"
  }
  condition {
    host_header {
      values = [
        aws_route53_record.graphql.fqdn]
    }
  }
}

resource "aws_autoscaling_attachment" "graphnode-graphql" {
  alb_target_group_arn   = aws_lb_target_group.graphnode-graphql.arn
  autoscaling_group_name = aws_autoscaling_group.autopilot_worker.name
}
