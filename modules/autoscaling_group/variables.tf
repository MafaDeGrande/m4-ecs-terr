variable "instance_type" {
  type        = string
  description = "Type of the instance"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "ID of the AMI used to launch the instance"
  default     = "ami-07b170996eca6bdf1"
}

variable "name" {
  type        = string
  description = "Name of the Auto Scaling Group"
}

#variable "cluster_name" {
#  type = string
#  description = "Name of the ecs cluster"
#}

variable "env" {
  type = string
  description = "Name of the environment"
}

variable "key_name" {
  type        = string
  description = "The name for the key pair"
}

variable "vpc_zone_identifier" {
  type        = list(string)
  description = "List of subnet IDs to launch resources in"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "alb_arn" {
  type        = string
  description = "ARN of a load balancer target group"
}
