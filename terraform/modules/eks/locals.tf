locals {
  # FIXED: Fixed the typo "llocals" -> "locals"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "your-team"
    Component   = "eks"
  }
}