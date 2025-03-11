# VPC Module
module "vpc" {
  # FIXED: Updated module path to use correct relative path
  source = "../../modules/vpc"

  vpc_cidr        = var.vpc_cidr
  web_subnet_cidr = var.web_subnet_cidr
  alb_subnet_cidr = var.alb_subnet_cidr
  api_subnet_cidr = var.api_subnet_cidr
  db_subnet_cidr  = var.db_subnet_cidr
  environment     = var.environment
  az_a            = var.az_a
  az_b            = var.az_b
}

# RDS Module
module "rds" {
  # FIXED: Updated module path to use correct relative path
  source = "../../modules/rds"

  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = values(module.vpc.private_subnets)
  web_security_group_id       = module.vpc.web_security_group_id
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  environment                 = var.environment
  db_name                     = var.db_name
  master_username             = var.master_username
}

# EKS Module
module "eks" {
  # FIXED: Updated module path to use correct relative path
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
}

module "tools" {
  # FIXED: Updated module path to use correct relative path
  source = "../../modules/tools"

  environment            = var.environment
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  depends_on = [
    module.eks
  ]
}