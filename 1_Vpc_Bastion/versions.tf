# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
     }
  }


    # Adding Backend as S3 for Remote State Storage
backend "s3" {
  bucket = "terraform-state-envs"
  key    = "stage/vpc-bastion/terraform.tfstate"
  region = "us-east-1" 

  # For State Locking
  dynamodb_table = "stage-vpc-bastion"    
  }  
}

# Terraform Provider Block
provider "aws" {
  region = "us-east-1"
}
