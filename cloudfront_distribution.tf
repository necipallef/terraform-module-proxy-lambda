variable "create_new_distribution" {
    type = bool
    description = "Should the integration deploy a new CloudFront distribution?"
    nullable = false
}

locals {
    fpcdn_origin_id = "fpcdn.io"
}

resource "aws_cloudfront_distribution" "fpjs_cloudfront_distribution" {
    count = var.create_new_distribution ? 1 : 0
    comment = "Fingerprint distribution (created via Terraform)"

    origin {
        domain_name = "fpcdn.io"
        origin_id = local.fpcdn_origin_id
        custom_origin_config {
            origin_protocol_policy = "https-only"
            http_port = 80
            https_port = 443
            origin_ssl_protocols = ["TLSv1.2"]
        }
        custom_header {
            name = "FPJS_SECRET_NAME"
            value = aws_secretsmanager_secret.secret-manager-secret-created-by-terraform.arn
        }
    }

    enabled = true

    http_version = "http1.1"

    price_class = "PriceClass_100"

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods = ["GET", "HEAD"]
        cache_policy_id = aws_cloudfront_cache_policy.fpjs-procdn-cache-policy.id
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Default AllViewer policy
        target_origin_id = local.fpcdn_origin_id
        viewer_protocol_policy = "https-only"
        compress = true

        lambda_function_association {
            event_type = "origin-request"
            lambda_arn = aws_lambda_function.fpjs_proxy_lambda.qualified_arn
            include_body = true
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}
