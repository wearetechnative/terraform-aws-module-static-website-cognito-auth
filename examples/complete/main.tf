module "docs_example_website" {

  source = "TechNative-B-V/static-website-cognito-auth/aws"

  name                            = "website_docs_example"
  domain                          = "subdomain.example.com"
  route53_zone_name               = "example.com."

  deploy_user_name                = "example_deployment_user"

  cognito_path_refresh_auth       = "/refreshauth"
  cognito_path_logout             = "/logout"
  cognito_path_parse_auth         = "/parseauth"
  cognito_refresh_token_validity  = 3650
  cognito_domain_prefix           = "login"

  providers = {
    aws.us-east-1: aws.us-east-1
  }
}

output "docs_example_website_deploy_key_id" {
  value = module.docs_example_website.iam_access_key_id
}

output "docs_example_website_deploy_key_secret" {
  value = module.docs_example_website.iam_access_key_secret
  sensitive = true
}

