variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs to attach to the LB"
}

variable "name" {
  type        = string
  description = "Name of the LB"
}

variable "tags" {
  description = "A map of tags to assign to the resource of load balancer"
  type        = map(string)
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "domain" {
  description = "The domain name"
  type        = string
  default     = "ipp.gzttk.org"
}
