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
  default     = "10.0.1.0/24"
}

variable "alb_subnet_cidr" {
  description = "CIDR block for alb subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "api_subnet_cidr" {
  description = "CIDR block for api subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for db subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "az_a" {
  description = "Availability zone A"
  type        = string
  default     = "us-east-2a"
}

variable "az_b" {
  description = "Availability zone B"
  type        = string
  default     = "us-east-2b"
}

# In modules/vpc/variables.tf, modules/rds/variables.tf, and modules/eks/variables.tf
variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}