variable "private_subnet_ids" {
  type        = list(string)
  description = "VPC subnet ID for the cache subnet group"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "group_name" {
  description = "The name of the security and subnet groups"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
