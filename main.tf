terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "s3dumb-frontend-host-terraform-state-dynamodb"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "s3dumb-frontend-host-running-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "ghostfolio-app"
  env  = "dev"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-${local.env}-${local.name}"
  cidr   = "10.0.0.0/16"

  azs                = data.aws_availability_zones.available.names
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
  tags               = var.tags
}

module "ecs" {
  source       = "./modules/ecs/"
  cluster_name = "ecs-${local.name}"
  env          = local.env
  asg_arn      = module.autoscaling_group.asg_arn
  alb_arn      = module.app_load_balancer.alb_arn
  image        = var.image 
  task_family  = "my-task-family:2"
  public_subnet_ids = module.vpc.public_subnets
  alb_security_group_id = module.app_load_balancer.security_group_id
  s3_bucket_arn = module.s3.s3_bucket_arn
}

module "aws_key_pair" {
  source   = "./modules/key_pair/"
  key_name = "tf_key"
}

module "autoscaling_group" {
  source              = "./modules/autoscaling_group/"
  name                = "${local.name}-asg"
  env                 = local.env
  cluster_name        = module.ecs.cluster_name
  key_name            = module.aws_key_pair.tf_key
  subnet_ids          = module.vpc.public_subnets
  vpc_id              = module.vpc.vpc_id
  alb_arn             = module.app_load_balancer.alb_arn
  depends_on          = [module.app_load_balancer]
}

module "app_load_balancer" {
  source  = "./modules/app_load_balancer/"
  name    = "${local.name}-alb"
  subnets = module.vpc.public_subnets
  vpc_id  = module.vpc.vpc_id
}

module "elasticache" {
  source                 = "./modules/elasticache/"
  vpc_id                 = module.vpc.vpc_id
  cluster_id             = "cluster-cache"
  private_subnet_id      = module.vpc.private_subnets[0]
  elasticache_group_name = "cache-subnet"
  security_group_name    = "elasticache-sg"
}

module "rds" {
  source             = "./modules/rds/"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  group_name         = "db-postgresql-sg"
  db_name            = "ghostfolio"
  db_username        = var.db_username
  db_password        = var.db_password
}

module "s3" {
  source      = "./modules/s3/"
  bucket_name = "${local.name}-env-file"
  depends_on  = [local_file.env_file]
}

resource "local_file" "env_file" {
  filename = "${path.cwd}/.env"

  content = <<EOT
POSTGRES_DB="${module.rds.db_name}"
POSTGRES_USER="${module.rds.db_username}"
POSTGRES_PASSWORD="${module.rds.db_password}"
DATABASE_URL="postgresql://${module.rds.db_username}:${module.rds.db_password}@${module.rds.endpoint}:5432/${module.rds.db_name}"
REDIS_HOST="${module.elasticache.redis_endpoint}"
REDIS_PORT="${module.elasticache.redis_port}"
ACCESS_TOKEN_SALT="${var.ACCESS_TOKEN_SALT}"
JWT_SECRET_KEY="${var.JWT_SECRET_KEY}"
EOT
}
