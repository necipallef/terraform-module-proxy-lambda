terraform {
  required_providers {
    random_id = {
      source = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}

resource "random_id" "integration_id" {
  byte_length = 6
}

locals {
  integration_id = random_id.integration_id.hex
}
