
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "terraform-aws-infrastructure" # Change this to your project name
    Owner       = "your-team"                    # Add your team/owner
  }
}