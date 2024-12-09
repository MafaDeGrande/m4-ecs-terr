module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name                       = var.name
  vpc_id                     = var.vpc_id
  subnets                    = var.subnets
  enable_deletion_protection = false

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name              = var.name
      port              = 80
      protocol          = "HTTP"
      target_type       = "instance"
      create_attachment = false
    }
  }

  #Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = var.tags
}

data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain
  zone_id     = data.aws_route53_zone.selected.zone_id

  validation_method   = "DNS"
  wait_for_validation = true
}
