locals {
  callback_urls = concat(["https://${var.domain}${var.cognito_path_parse_auth}"], var.cognito_additional_callbacks, formatlist("%s${var.cognito_path_parse_auth}", var.cognito_additional_redirects))
  logout_urls   = concat(["https://${var.domain}${var.cognito_path_logout}"], formatlist("%s${var.cognito_path_logout}", var.cognito_additional_redirects))
}

module "cognito-user-pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "1.7.0"

  user_pool_name         = "${var.name}-userpool"
  domain                 = "${var.cognito_domain_prefix}.${aws_route53_record.website-domain.name}"
  domain_certificate_arn = module.acm.acm_certificate_arn

  admin_create_user_config_email_subject = "You have a new account for ${var.domain}"
  admin_create_user_config_email_message = "<p>We created a new account for you to access <a href='https://${var.domain}'>${var.domain}</a>.</p><p>Login with username <strong>{username}</strong> and <strong>{####}</strong> as password. After you have logged in for the first time you must set a new password.</p>"

  # TODO MAKE VAR
  clients = [
    {
      name                         = "${var.name}-client"
      supported_identity_providers = var.cognito_client_supported_identity_providers

      generate_secret                      = true
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_flows                  = ["code","implicit"]
      allowed_oauth_scopes                 = ["openid"]
      callback_urls                        = local.callback_urls
      logout_urls                          = local.logout_urls
    },
  ]

  string_schemas = var.string_schemas
}
