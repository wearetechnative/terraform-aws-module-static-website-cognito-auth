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

variable "deploy_user_name" {
  description = "the username of the deploy user"
  type        = string
}
