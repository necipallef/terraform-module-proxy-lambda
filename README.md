## How to Install

### Using a new CloudFront distribution

1. Create a new directory `mkdir fingerprint_integration` and go inside `cd fingerprint_integration`
2. Run `terraform init`
3. Create a file `touch main.tf` and add below content, do not forget to replace placeholders (`AGENT_DOWNLOAD_PATH_HERE`, `RESULT_PATH_HERE`, `PROXY_SECRET_HERE`):
    ```terraform
    module "fingerprint_cloudfront_integration" {
      source = "git@github.com:necipallef/terraform-module-proxy-lambda.git/?ref=v0.3.0"
    
      create_new_distribution  = true
      fpjs_agent_download_path = "AGENT_DOWNLOAD_PATH_HERE"
      fpjs_get_result_path = "RESULT_PATH_HERE"
      fpjs_pre_shared_secret = "PROXY_SECRET_HERE"
    }
    ```
4. Run `terraform plan`, if all looks good run `terraform apply`

### Using existing CloudFront distribution

1. Create a file called `fingerprint.tf` and add below content:
    ```terraform
    module "fingerprint_cloudfront_integration" {
        source = "git@github.com:necipallef/terraform-module-proxy-lambda.git/?ref=v0.3.0"

        create_new_distribution = false
        fpjs_agent_download_path = "AGENT_DOWNLOAD_PATH_HERE"
        fpjs_get_result_path = "RESULT_PATH_HERE"
        fpjs_pre_shared_secret = "PROXY_SECRET_HERE"
    }
    
    locals {
        fpcdn_origin_id = "fpcdn.io"
    }

    ```
2. Go to your CloudFront distribution block and add below content, do not forget to replace placeholders (`AGENT_DOWNLOAD_PATH_HERE`, `RESULT_PATH_HERE`, `PROXY_SECRET_HERE`, `YOUR_INTEGRATION_PATH_HERE`):
    ```terraform
    resource "aws_cloudfront_distribution" "cloudfront_dist" {
      // more code here
    
        #region fingerprint start
        
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
            value = module.fingerprint_cloudfront_integration.fpjs_secret_manager_arn
          }
        }
        
        ordered_cache_behavior {
          path_pattern = "YOUR_INTEGRATION_PATH_HERE/*"
        
          allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
          cached_methods = ["GET", "HEAD"]
          cache_policy_id = module.fingerprint_cloudfront_integration.fpjs_cache_policy_id
          origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Default AllViewer policy
          target_origin_id = local.fpcdn_origin_id
          viewer_protocol_policy = "https-only"
          compress = true
        
          lambda_function_association {
            event_type = "origin-request"
            lambda_arn = module.fingerprint_cloudfront_integration.fpjs_proxy_lambda_arn
            include_body = true
          }
        }
        
        #endregion
      
      // more code here
    }
    ```
3. Run `terraform plan`, if all looks good run `terraform apply`

> [!NOTE]
> If your project doesn't use `hashicorp/random` module, then you will need to run `terraform init -upgrade`.

## Todo
- [ ] Support for `DomainNames` for newly created CloudFront distribution
- [ ] Support for `ACMCertificateARN`
- [ ] management lambda related resources
- [ ] publish on Hashicorp account
