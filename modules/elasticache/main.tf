resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.subnet.name
  security_group_ids = [aws_security_group.elasticache_sg.id]
  tags        = var.tags
}

resource "aws_elasticache_subnet_group" "subnet" {
  name       = var.security_group_name
  subnet_ids = [var.private_subnet_id]
}

resource "aws_security_group" "elasticache_sg" {
  name        = var.elasticache_group_name
  description = "Security group for ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]
  }
}
