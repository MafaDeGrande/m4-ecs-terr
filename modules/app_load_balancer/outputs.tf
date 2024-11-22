output "alb_arn" {
  value = module.alb.target_groups["ex-instance"].arn
  description = "The ID and ARN of the load balancer we created"
}

output "dns_name" {
  value = module.alb.dns_name
  description = "The DNS name of the load balancer"
}
