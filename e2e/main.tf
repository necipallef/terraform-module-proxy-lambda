provider "aws" {
  region  = "us-west-2"
}

module "fingerprint_cloudfront_integration" {
  source                   = "../"
  fpjs_agent_download_path = var.fpjs_agent_download_path
  fpjs_get_result_path     = var.fpjs_get_result_path
  fpjs_shared_secret       = var.fpjs_shared_secret
}

variable "fpjs_agent_download_path" {
  type = string
}
variable "fpjs_get_result_path" {
  type = string
}
variable "fpjs_shared_secret" {
  type = string
}
