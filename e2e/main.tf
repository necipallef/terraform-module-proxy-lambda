module "fingerprint_cloudfront_integration" {
  source = "../"

  fpjs_agent_download_path = "agent"
  fpjs_get_result_path     = "result"
  fpjs_shared_secret       = "secret"
}
