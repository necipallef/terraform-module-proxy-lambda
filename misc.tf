terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57.0"
    }
  }
}

resource "random_id" "integration_id" {
  byte_length = 6
}

locals {
  integration_id = random_id.integration_id.hex
}
