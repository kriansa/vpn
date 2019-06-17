data "aws_route53_zone" "main" {
  name = "${var.base_domain_name}."
}

resource "aws_route53_record" "a_entry" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.vpn_subdomain}.${data.aws_route53_zone.main.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.main.public_ip]
}
