terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


module "network" {
  source = "../modules/network"
  prefix = var.prefix
}

module "iam" {
  source = "../modules/iam"
  prefix = var.prefix
}

