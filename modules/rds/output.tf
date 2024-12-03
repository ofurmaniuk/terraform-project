output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "database_name" {
  description = "The name of the database"
  value       = aws_rds_cluster.aurora.database_name
}

output "aurora_security_group_id" {
  description = "The ID of the Aurora security group"
  value       = aws_security_group.aurora.id
}