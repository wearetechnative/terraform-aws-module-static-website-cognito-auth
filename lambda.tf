locals {
  functions = toset(
    ["check-auth", "http-headers", "parse-auth", "refresh-auth", "rewrite-trailing-slash", "sign-out"]
  )
}

# WARNING this line has been removed:
# "Content-Security-Policy": "default-src 'none'; img-src 'self'; script-src 'self' https://code.jquery.com https://stackpath.bootstrapcdn.com; style-src 'self' 'unsafe-inline' https://stackpath.bootstrapcdn.com; object-src 'none'; connect-src 'self' https://*.amazonaws.com https://*.amazoncognito.com",
module "lambda_function" {
  for_each = local.functions

  source = "./modules/lambda"

  name     = var.name
  function = each.value
  configuration = jsondecode(<<EOF
{
  "userPoolArn": "${module.cognito-user-pool.arn}",
  "clientId": "${module.cognito-user-pool.client_ids[0]}",
  "clientSecret": "${module.cognito-user-pool.client_secrets[0]}",
  "oauthScopes": ["openid"],
  "cognitoAuthDomain": "${var.cognito_domain_prefix}.${var.domain}",
  "redirectPathSignIn": "${var.cognito_path_parse_auth}",
  "redirectPathSignOut": "${var.cognito_path_logout}",
  "redirectPathAuthRefresh": "${var.cognito_path_refresh_auth}",
  "cookieSettings": { "idToken": null, "accessToken": null, "refreshToken": null, "nonce": null },
  "mode": "spaMode",
  "httpHeaders": {
      "Strict-Transport-Security": "max-age=31536000; includeSubdomains; preload",
      "Referrer-Policy": "same-origin",
      "X-XSS-Protection": "1; mode=block",
      "X-Frame-Options": "DENY",
      "X-Content-Type-Options":  "nosniff"
  },
  "logLevel": "none",
  "nonceSigningSecret": "jvfg108gfhjhg!&%j91kt",
  "cookieCompatibility": "amplify",
  "additionalCookies": {},
  "requiredGroup": ""
}
EOF
  )

  providers = {
    aws = aws.us-east-1
  }
}
