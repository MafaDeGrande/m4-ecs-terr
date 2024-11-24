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
  task_exec_iam_role_arn = aws_iam_role.ecs_exec.arn

  capacity_provider_strategy = {
    ex_1 = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["ex_1"].name
      weight = 1
      base   = 1
    }
  }

  container_definitions = {
    (local.container_name) = {
      cpu = 512
      memory = 1024
      image = local.image_uri
      environment_files = [
        {
          value = "${var.s3_bucket_arn}/.env"
          type = "s3"
        }
      ]
      port_mappings = [
        {
          name = local.container_name
          containerPort = local.container_port
          protocol = "tcp"
        }
      ]
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

resource "aws_iam_role" "ecs_exec" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_policy" {
  name        = aws_iam_role.ecs_exec.name
  description = "Policy for ECS to access services"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect   = "Allow"
        Action   = [
          "s3:GetObject"
        ]
        Resource = [
          "${var.s3_bucket_arn}/.env"
      ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${var.s3_bucket_arn}"
      ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role = aws_iam_role.ecs_exec.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

