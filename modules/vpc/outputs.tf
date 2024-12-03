output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "Map of private subnet IDs"
  value = {
    api = aws_subnet.api.id
    db  = aws_subnet.db.id
  }
}

output "public_subnets" {
  description = "Map of public subnet IDs"
  value = {
    web = aws_subnet.web.id
    alb = aws_subnet.alb.id
  }
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}
