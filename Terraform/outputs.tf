output "wordpress_ip" {
  value = aws_instance.wordpress.public_ip
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}