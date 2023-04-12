module "example_com_website" {

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

  #ACTIVATE AFTER OFFICE365 ActiveDirectory App Creation
  #cognito_client_supported_identity_providers = ["COGNITO", "OFFICE365"]

  providers = {
    aws.us-east-1: aws.us-east-1
  }
}

# ACTIVATE AFTER OFFICE365 ActiveDirectory App Creation
#resource "aws_cognito_identity_provider" "example_com_website_identity_provider" {
#  user_pool_id  = module.example_com_website.cognito_user_pool_id
#  provider_name = "OFFICE365"
#  provider_type = "SAML"
#
#  provider_details = {
#    MetadataURL = "https://login.microsoftonline.com/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/federationmetadata/2007-06/federationmetadata.xml?appid=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#    SLORedirectBindingURI = "https://login.microsoftonline.com/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/saml2"
#    SSORedirectBindingURI = "https://login.microsoftonline.com/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/saml2"
#  }
#
#  attribute_mapping = {
#    email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress,CUSTOM_ATTR_NAME=http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
#  }
#}

output "docs_example_website_bucket_id" {
  value = module.example_com_website.s3_bucket_id
}

output "docs_example_website_deploy_key_id" {
  value = module.example_com_website.iam_access_key_id
}

output "docs_example_website_deploy_key_secret" {
  value = module.example_com_website.iam_access_key_secret
  sensitive = true
}

output "example_com_website_cli_cmd" {
  value = "aws cognito-idp add-custom-attributes --region ${data.aws_region.current.name} --user-pool-id ${module.example_com_website.cognito_user_pool_id} --custom-attributes Name=\"CUSTOM_ATTR_NAME\",AttributeDataType=\"String\",DeveloperOnlyAttribute=false,Required=false,Mutable=true,StringAttributeConstraints=\"{MinLength=0,MaxLength=255}\""
}

output "example_com_website_office365_saml_entity_id" {
  value = "urn:amazon:cognito:sp:${module.example_com_website.cognito_user_pool_id}"
}

output "example_com_website_office365_reply_url" {
  value = "https://login.subdomain.example.com/saml2/idpresponse"
}
