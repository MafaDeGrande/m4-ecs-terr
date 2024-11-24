output "redis_endpoint" {
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
  description = "The adress of the node"
}

output "redis_port" {
  value       = aws_elasticache_cluster.redis.port
  description = "Port of the redis"
}
