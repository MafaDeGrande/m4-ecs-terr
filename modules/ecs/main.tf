locals {
  name = var.cluster_name
  image_uri = var.image
  container_name = "ghostfolio"
  container_port = 80
  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"
  cluster_name = local.name
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    ex_1 = {
      auto_scaling_group_arn = var.asg_arn
    }
  }
  tags = local.tags 
} 

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  name =  local.name 
  cluster_arn = module.ecs_cluster.arn
  requires_compatibilities = ["EC2"]
  create_task_exec_iam_role = false
  task_definition_arn = data.aws_ecs_task_definition.task_defi.arn 

  capacity_provider_strategy = {
    ex_1 = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["ex_1"].name
      weight = 1
      base   = 1
    }
  }

  load_balancer = {
    service = {
      target_group_arn = var.alb_arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = var.public_subnet_ids
  security_group_rules ={
    alb_http_ingress = {
      type  = "ingress"
      from_port = local.container_port
      to_port = local.container_port
      protocol = "tcp"
      description = "Service port"
      source_security_group_id = var.alb_security_group_id 
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}

data "aws_ecs_task_definition" "task_defi" {
  task_definition = var.task_family 
}
