#data "aws_canonical_user_id" "current" {}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  zone_id                   = data.aws_route53_zone.this.id
  validation_method         = "DNS"

  providers = {
    aws = aws.us-east-1
  }
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases = [var.domain]

  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  create_origin_access_identity = true
  origin_access_identities = {
    website = "Access website content"
  }

  origin = {
    s3 = {
      domain_name = module.website_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "website"
      }
    }

    dummy = {
      domain_name = "example.com"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true

    lambda_function_association = {
      viewer-request = {
        lambda_arn = module.lambda_function["check-auth"].lambda_function_qualified_arn
      }

      origin-response = {
        lambda_arn   = module.lambda_function["http-headers"].lambda_function_qualified_arn
        include_body = false
      }

      origin-request = {
        lambda_arn   = module.lambda_function["rewrite-trailing-slash"].lambda_function_qualified_arn
        include_body = false
      }
    }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = var.cognito_path_parse_auth
      target_origin_id       = "dummy"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

      lambda_function_association = {
        viewer-request = {
          lambda_arn = module.lambda_function["parse-auth"].lambda_function_qualified_arn
        }
      }
    },
    {
      path_pattern           = var.cognito_path_refresh_auth
      target_origin_id       = "dummy"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

      lambda_function_association = {
        viewer-request = {
          lambda_arn = module.lambda_function["refresh-auth"].lambda_function_qualified_arn
        }
      }
    },
    {
      path_pattern           = var.cognito_path_logout
      target_origin_id       = "dummy"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

      lambda_function_association = {
        viewer-request = {
          lambda_arn = module.lambda_function["sign-out"].lambda_function_qualified_arn
        }
      }
    },

  ]

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

}

