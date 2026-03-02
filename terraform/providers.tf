terraform {
  # Ensures you use a stable Terraform version
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
  
  # Add default tags to automatically 
  # label every resource created by this project.
  default_tags {
    tags = {
      Project   = "StockTerrain"
      ManagedBy = "Terraform"
    }
  }
}