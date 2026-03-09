terraform {
  required_version = "~> 1.7" 

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  
  # Add default tags and label every resource
  default_tags {
    tags = {
      Project   = "StockTerrain"
      ManagedBy = "Terraform"
    }
  }
}