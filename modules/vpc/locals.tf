locals {
  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "terraform-aws-infrastructure"
      Owner       = "your-team"
      Component   = "networking"
    },
    var.tags
  )
}