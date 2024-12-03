terraform {
  backend "s3" {
    bucket  = "ofurmaniuk"
    key     = "terraform-project/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}