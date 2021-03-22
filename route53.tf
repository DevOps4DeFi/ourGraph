data "aws_lb" "alb" {
  name = var.lb_name
}
data "aws_route53_zone" "rootzone" {
  name = local.route53_root_fqdn
}
resource "aws_route53_record" "graphql" {
  name    = var.app_name
  type    = "A"
  zone_id = data.aws_route53_zone.rootzone.zone_id
  alias {
    evaluate_target_health = false
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
  }
}
