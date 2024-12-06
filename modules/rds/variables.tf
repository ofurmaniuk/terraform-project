variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS deployment"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "ID of the web security group for ingress rules"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

# In modules/vpc/variables.tf, modules/rds/variables.tf, and modules/eks/variables.tf
variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}