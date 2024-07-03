variable "fpjs_get_result_path" {
    type = string
    description = "request path used to send identification requests (aka FPJS_GET_RESULT_PATH)"

    validation {
        condition = can(regex("^([a-zA-Z0-9\\-])+$", var.fpjs_get_result_path))
        error_message = "value should only consist of alphanumeric values and dashes"
    }
}

variable "fpjs_agent_download_path" {
    type = string
    description = "request path used to send ProCDN requests (aka FPJS_AGENT_DOWNLOAD_PATH)"

    validation {
        condition = can(regex("^([a-zA-Z0-9\\-])+$", var.fpjs_agent_download_path))
        error_message = "value should only consist of alphanumeric values and dashes"
    }
}

variable "fpjs_pre_shared_secret" {
    type = string
    sensitive = true
    description = "shared secret created on the Fingerprint dashboard (aka FPJS_PRE_SHARED_SECRET)"

    validation {
        condition = can(regex("^([a-zA-Z0-9\\-])+$", var.fpjs_pre_shared_secret))
        error_message = "value should only consist of alphanumeric values and dashes"
    }
}

resource "aws_secretsmanager_secret" "secret-manager-secret-created-by-terraform" {
    name = "fingerprint-pro-cloudfront-integration-settings-secret-${local.integration_id}"
    description = "AWS Secret with a custom Fingerprint integration settings (created via Terraform)"
}

resource "aws_secretsmanager_secret_version" "paths" {
    secret_id = aws_secretsmanager_secret.secret-manager-secret-created-by-terraform.id
    secret_string = jsonencode(
        {
            fpjs_get_result_path = var.fpjs_get_result_path
            fpjs_agent_download_path = var.fpjs_agent_download_path
            fpjs_pre_shared_secret = var.fpjs_pre_shared_secret
        }
    )
}
