resource "aws_launch_template" "template_finance_app" {
  name_prefix   = local.name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_tls.id]
  }

  user_data = filebase64("${path.cwd}/userdata.sh")
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.finance_app.name
  lb_target_group_arn    = var.alb_arn
}

resource "aws_autoscaling_group" "finance_app" {
  name                = local.name
  vpc_zone_identifier = var.vpc_zone_identifier
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1

  launch_template {
    id      = aws_launch_template.template_finance_app.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "finance_app" {
  name                   = "cpu_utilization"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.finance_app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

# Security group 
resource "aws_security_group" "allow_tls" {
  name        = local.name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
  tags        = local.tags
}

locals {
  name = "${var.name}-${var.env}"
  tags = {
    Name = var.name
    Env  = var.env
  }

  ingress_rules = [
    {
      name       = "allow_ssh"
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      name       = "allow_http"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    }
  ]
  egress_rules = [
    {
      name        = "allow_all_traffic_ipv4"
      cidr_block  = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  ]
}

resource "aws_vpc_security_group_ingress_rule" "allow_ingress_ipv4" {
  for_each          = { for rule in local.ingress_rules : rule.name => rule }
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.from_port
  ip_protocol       = each.value.protocol
  to_port           = each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_ipv4" {
  for_each          = { for rule in local.egress_rules : rule.name => rule }
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = each.value.cidr_block
  ip_protocol       = each.value.ip_protocol
}
