locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "your-team"
    Component   = "database"
  }
}