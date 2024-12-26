terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

module "consolify" {
  source  = "../../"
  enabled = true
  content = file(data.terraform_remote_state.state.config.path)
}

data "terraform_remote_state" "state" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}

resource "aws_s3_bucket" "test" {
  bucket = "name-z1222zzzz666"
}


resource "aws_cloudwatch_log_group" "test" {
  name = "test"
}

resource "aws_cloudwatch_log_group" "test2" {
  name = "/lambda/test"
}

resource "aws_iam_role" "lambda_role" {
  name               = "example-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "eks_role" {
  name               = "example-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}



output "debug" {
  value = module.consolify.linkable_resources
}