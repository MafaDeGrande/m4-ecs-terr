variable "private_subnet_id" {
  type        = string
  description = "VPC subnet ID for the cache subnet group"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "cluster_id" {
  type        = string
  description = "Group identifier"
}

variable "elasticache_group_name" {
  description = "The name of the elasticache group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}
