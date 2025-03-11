locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "terraform-aws-infrastructure"
    Owner       = "your-team"
    Component   = "networking"
  }

  # VPC specific tags
  vpc_tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc"
  })

  # Subnet tags
  subnet_tags = {
    public = merge(local.common_tags, {
      Tier = "public"
      Type = "Public"
    })
    private = merge(local.common_tags, {
      Tier = "private"
      Type = "Private"
    })
  }
}