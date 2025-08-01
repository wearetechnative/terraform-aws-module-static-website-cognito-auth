terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0, < 3.0.0"
    }
  }
}

locals {
  path = "${path.module}/../../external/cloudfront-authorization-at-edge/${var.function}"
  path_function = "${local.path}/bundle.js"
  path_configuration = "${local.path}/configuration.json"
}

resource "local_file" "function_configuration" {
  filename = local.path_configuration
  content  = jsonencode(var.configuration)
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = local.path
  output_path = "${local.path}-v1.zip"
  output_file_mode = "0666"

  depends_on = [
    local_file.function_configuration,
  ]
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.0.1"

  function_name = "${var.name}-${var.function}"
  handler       = "bundle.handler"
  runtime       = "nodejs22.x"

  publish        = true
  lambda_at_edge = true

  create_package         = false
  local_existing_package = "${local.path}-v1.zip"

  tracing_mode          = "Active"

  depends_on = [
    data.archive_file.archive,
    local_file.function_configuration,
  ]
}
