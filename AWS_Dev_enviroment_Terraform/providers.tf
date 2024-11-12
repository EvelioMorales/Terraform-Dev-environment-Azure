terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = "us-west-2"
  shared_credentials_files = ["C:/Users/user/Desktop/aws_creds"]
  profile                  = "vscode"
}