variable "cluster_name" {
  type        = string
  description = "Name of the ecs cluster"
}

variable "env" {
  type        = string
  description = "Name of the environment"
}

variable "asg_arn" {
  type = string
  description = "The arn of the aws_autoscaling_group"
}

variable "image" {
  type = string
  description = "Image of the app"
}

variable "alb_arn" {
  type        = string
  description = "ARN of a load balancer target group"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "VPC subnet ID for the  subnet group"
}

variable "alb_security_group_id" {
  type = string
  description = "Security group id associated with the task"
}

variable "s3_bucket_arn" {
  type = string
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}

variable "task_family" {
  type = string
  description = "Family for the latest ACTIVE revision, family and revision (family:revision) "
}
