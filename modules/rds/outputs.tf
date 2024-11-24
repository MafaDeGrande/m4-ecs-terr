output "endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "Endpoint of the postgres db"
  sensitive   = true
}

output "db_name" {
  value       = aws_db_instance.default.db_name
  description = "Name of the postgres db"
}

output "db_username" {
  value       = aws_db_instance.default.username
  description = "Username of the postgres db"
  sensitive   = true
}

output "db_password" {
  value       = aws_db_instance.default.password
  description = "Password of the postgres db"
  sensitive   = true
}

