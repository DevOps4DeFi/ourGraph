locals {
  build_index_listener = var.index_lb_name != null ? 1 : 0
}
data "aws_lb" "graph_alb" {
  name = var.graph_lb_name
}
data "aws_lb" "index_alb" {
  count = local.build_index_listener
  name = var.index_lb_name
}

resource "aws_lb_target_group" "graphql" {
  name_prefix     = "gn-gql"
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
resource "aws_lb_listener_rule" "graphql" {
  listener_arn = var.graphql_lb_listener_arn
  action {
    target_group_arn = aws_lb_target_group.graphql.arn
    type = "forward"
  }
  condition {
    host_header {
      values = [
        aws_route53_record.graphql.fqdn]
    }
  }
}

resource "aws_autoscaling_attachment" "graphql" {
  alb_target_group_arn   = aws_lb_target_group.graphql.arn
  autoscaling_group_name = aws_autoscaling_group.graphnode.name
  depends_on = [aws_lb_listener_rule.graphql]
}

resource "aws_lb_target_group" "graph-index" {
  count = local.build_index_listener
  name_prefix     = "gn-idx"
  port     = "8020"
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  tags = {
    Name = "graph-index"
  }
  health_check { ##TODO figure out a better healthcheck maybe getting data from the monitoring/management ports
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 8020
  }
}

## TODO ports 8020[JSON-RPC admin], 8030[IndexNode], 8040[Metrics] may need to be exposed to the internet
## If so they need their own target groups.

resource "aws_lb_listener_rule" "graph-index" {
  count = local.build_index_listener
  listener_arn = var.index_lb_listener_arn
  action {
    target_group_arn = aws_lb_target_group.graph-index[0].arn
    type = "forward"
  }
  condition {
    host_header {
      values = [
        aws_route53_record.graph-idx[00].fqdn]
    }
  }
}

resource "aws_autoscaling_attachment" "graph-index" {
  count = local.build_index_listener
  alb_target_group_arn   = aws_lb_target_group.graph-index[0].arn
  autoscaling_group_name = aws_autoscaling_group.graphnode.name
  depends_on = [aws_lb_listener_rule.graph-index]
}
