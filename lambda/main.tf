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
  function_name  = "YourSuperCoolFunctionName"
  python_version = "python3.12"
}
