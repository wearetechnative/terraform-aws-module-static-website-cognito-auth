variable "name" {
  description = "A unique string to use for this module to make sure resources do not clash with others"
  type        = string
}

variable "domain" {
  description = "The primary domain name to use for the website"
  type        = string
}

variable "domain_aliases" {
  description = "A set of any alternative domain names. Typically this would just contain the same as custom_domain but prefixed by www."
  type        = set(string)
  default     = []
}

variable "route53_zone_name" {
  description = "The name of the hosted zone in Route53 where the SSL certificates will be created"
  type        = string
}

variable "cognito_path_refresh_auth" {
  description = "Path relative to `custom_domain` to redirect to when a token refresh is required"
  default     = "/refreshauth"
}

variable "cognito_path_logout" {
  description = "Path relative to custom_domain to redirect to after logging out"
  default     = "/"
}

variable "cognito_path_parse_auth" {
  description = "Path relative to custom_domain to redirect to upon successful authentication"
  default     = "/parseauth"
}

variable "cognito_additional_redirects" {
  description = "Additional URLs to allow cognito redirects to"
  type        = list(string)
  default     = []
}

variable "cognito_refresh_token_validity" {
  description = "Time until the refresh token expires and the user will be required to log in again"
  default     = 3650
}

variable "cognito_domain_prefix" {
  description = "The first part of the hosted UI login domain, as in https://[COGNITO_DOMAIN_PREFIX].[CUSTOM_DOMAIN]/"
  type        = string
  default     = "login"
}

#variable "deploy_user_create" {
#  description = "When true a deploy user will be created."
#  default     = false
#  type        = bool
#}

variable "cognito_client_supported_identity_providers" {
  description = "List of identity providers"
  type        = list(string)
  default     = ["COGNITO"]
}

variable "deploy_user_name" {
  description = "the username of the deploy user"
  type        = string
}

variable "string_schemas" {
  description = "String schemas to include"
  type = list(object({
    attribute_data_type = string
    developer_only_attribute = bool
    mutable = bool
    name = string
    required = bool
    string_attribute_constraints = object({
      min_length = number
      max_length = number
    })
  }))
  default = []
}

variable "bucket_policy_addition" {
  description = "Additional S3 policies in Terraform format. Can be derived using jsondecode(iam_policy_document.json)."
  type = any
  default = null
}

variable "region" {
  description = "AWS Region"
  type = string
}
