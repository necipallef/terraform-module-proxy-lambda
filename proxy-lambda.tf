data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    sid    = "AllowAwsToAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "fpjs_proxy_lambda" {
  name = "AWSSecretAccess"
  role = aws_iam_role.fpjs_proxy_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.fpjs_proxy_lambda_secret.arn
      },
    ]
  })
}

resource "aws_iam_role" "fpjs_proxy_lambda" {
  name               = "fingerprint-pro-lambda-role-${local.integration_id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_s3_object" "fpjs_integration_s3_bucket" {
  bucket = "fingerprint-pro-cloudfront-integration"
  key    = "v2/lambda_latest.zip"
}

resource "aws_lambda_function" "fpjs_proxy_lambda" {
  s3_bucket        = data.aws_s3_object.fpjs_integration_s3_bucket.bucket
  s3_key           = data.aws_s3_object.fpjs_integration_s3_bucket.key
  function_name    = "fingerprint-pro-cloudfront-lambda-${local.integration_id}"
  role             = aws_iam_role.fpjs_proxy_lambda.arn
  handler          = "fingerprintjs-pro-cloudfront-lambda-function.handler"
  source_code_hash = data.aws_s3_object.fpjs_integration_s3_bucket.etag

  runtime = "nodejs20.x"

  publish = true
}

output "fpjs_proxy_lambda_arn" {
  value       = aws_lambda_function.fpjs_proxy_lambda.qualified_arn
  description = "Fingerprint integration proxy lambda ARN"
}
