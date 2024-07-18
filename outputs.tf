output "fpjs_cache_policy_id" {
  value       = aws_cloudfront_cache_policy.fpjs_procdn.id
  description = "Fingerprint integration cache policy id"
}

output "fpjs_proxy_lambda_arn" {
  value       = aws_lambda_function.fpjs_proxy_lambda.qualified_arn
  description = "Fingerprint integration proxy lambda ARN"
}

output "fpjs_secret_manager_arn" {
  value       = aws_secretsmanager_secret.fpjs_proxy_lambda_secret.arn
  description = "Fingerprint secrets integration manager secret ARN"
}
