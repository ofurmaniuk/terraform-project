variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs"
  type        = map(string)
}

variable "public_subnet_ids" {
  description = "Map of public subnet IDs"
  type        = map(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.large"]
}

# In modules/vpc/variables.tf, modules/rds/variables.tf, and modules/eks/variables.tf
variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}