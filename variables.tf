variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block"
  }
}

variable "web_subnet_cidr" {
  description = "CIDR block for web subnet"
  type        = string
}

variable "alb_subnet_cidr" {
  description = "CIDR block for alb subnet"
  type        = string
}

variable "api_subnet_cidr" {
  description = "CIDR block for api subnet"
  type        = string
}

variable "db_subnet_cidr" {
  description = "CIDR block for db subnet"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "az_a" {
  description = "Availability zone A"
  type        = string
}

variable "az_b" {
  description = "Availability zone B"
  type        = string
}

variable "eks_node_security_group_id" {
  description = "Security group ID of the EKS node group"
  type        = string
}