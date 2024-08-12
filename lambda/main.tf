terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  function_name  = "GPXify"
  python_version = "python3.12"
}
