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
  env = "dev"
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
  tags = var.tags
}

module "ecs" {
  source = "./modules/ecs"
  #cluster_name = "ecs-${local.name}"
}

module "aws_key_pair" {
  source   = "./modules/key_pair/"
  key_name = "tf_key"
}

module "autoscaling_group" {
  source              = "./modules/autoscaling_group/"
  name                = "${local.name}-asg"
  env                 = local.env
  #cluster_name        = module.ecs.cluster_name
  key_name            = module.aws_key_pair.tf_key
  vpc_zone_identifier = module.vpc.public_subnets
  vpc_id              = module.vpc.vpc_id
  alb_arn             = module.app_load_balancer.alb_arn
  depends_on = [module.app_load_balancer]
}

module "app_load_balancer" {
  source        = "./modules/app_load_balancer/"
  name          = "${local.name}-alb"
  subnets       = module.vpc.public_subnets
  vpc_id        = module.vpc.vpc_id
}
