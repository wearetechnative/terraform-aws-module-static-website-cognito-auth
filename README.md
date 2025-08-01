# Terraform AWS Static Website Cognito Auth ![](https://img.shields.io/github/actions/workflow/status/TechNative-B-V/terraform-aws-static-website-cognito-auth/tflint.yaml)

<!-- SHIELDS -->

This module implements a s3 bucket for hosting a static website behind a
cognito login.

WARNING THIS PROJECT IS WIP.

[![](we-are-technative.png)](https://www.technative.nl)


## Usage

Below an example how to use this module ...

```hcl
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

  string_schemas = [
    {
      attribute_data_type = "String"
      developer_only_attribute = false
      mutable = true
      name = "office365tn"
      required = false
      string_attribute_constraints = {
        min_length = 1
        max_length = 256
      }
    }
  ]

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
```

## Credits

This module was forked from [terraform-aws-website-secure](https://github.com/timmeinerzhagen/terraform-aws-website-secure) (MIT).

Also code from [terraform-aws-website](https://github.com/bwindsor/terraform-aws-website) was included (MIT).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0, < 3.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 5.0.0 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | terraform-aws-modules/cloudfront/aws | 3.2.1 |
| <a name="module_cognito-user-pool"></a> [cognito-user-pool](#module\_cognito-user-pool) | lgallard/cognito-user-pool/aws | 1.7.0 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | ./modules/lambda | n/a |
| <a name="module_website_bucket"></a> [website\_bucket](#module\_website\_bucket) | terraform-aws-modules/s3-bucket/aws | 5.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.user_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_route53_record.cognito-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.website-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket_policy.bucket_policy_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_iam_policy_document.s3_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_policy_addition"></a> [bucket\_policy\_addition](#input\_bucket\_policy\_addition) | Additional S3 policies in Terraform format. Can be derived using jsondecode(iam\_policy\_document.json). | `any` | `null` | no |
| <a name="input_cognito_additional_callbacks"></a> [cognito\_additional\_callbacks](#input\_cognito\_additional\_callbacks) | Additional URLs to allow cognito callbacks to | `list(string)` | `[]` | no |
| <a name="input_cognito_additional_redirects"></a> [cognito\_additional\_redirects](#input\_cognito\_additional\_redirects) | Additional URLs to allow cognito redirects to | `list(string)` | `[]` | no |
| <a name="input_cognito_client_supported_identity_providers"></a> [cognito\_client\_supported\_identity\_providers](#input\_cognito\_client\_supported\_identity\_providers) | List of identity providers | `list(string)` | <pre>[<br/>  "COGNITO"<br/>]</pre> | no |
| <a name="input_cognito_domain_prefix"></a> [cognito\_domain\_prefix](#input\_cognito\_domain\_prefix) | The first part of the hosted UI login domain, as in https://[COGNITO_DOMAIN_PREFIX].[CUSTOM_DOMAIN]/ | `string` | `"login"` | no |
| <a name="input_cognito_path_logout"></a> [cognito\_path\_logout](#input\_cognito\_path\_logout) | Path relative to custom\_domain to redirect to after logging out | `string` | `"/"` | no |
| <a name="input_cognito_path_parse_auth"></a> [cognito\_path\_parse\_auth](#input\_cognito\_path\_parse\_auth) | Path relative to custom\_domain to redirect to upon successful authentication | `string` | `"/parseauth"` | no |
| <a name="input_cognito_path_refresh_auth"></a> [cognito\_path\_refresh\_auth](#input\_cognito\_path\_refresh\_auth) | Path relative to `custom_domain` to redirect to when a token refresh is required | `string` | `"/refreshauth"` | no |
| <a name="input_cognito_refresh_token_validity"></a> [cognito\_refresh\_token\_validity](#input\_cognito\_refresh\_token\_validity) | Time until the refresh token expires and the user will be required to log in again | `number` | `3650` | no |
| <a name="input_deploy_user_name"></a> [deploy\_user\_name](#input\_deploy\_user\_name) | the username of the deploy user | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The primary domain name to use for the website | `string` | n/a | yes |
| <a name="input_domain_aliases"></a> [domain\_aliases](#input\_domain\_aliases) | A set of any alternative domain names. Typically this would just contain the same as custom\_domain but prefixed by www. | `set(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | A unique string to use for this module to make sure resources do not clash with others | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | The name of the hosted zone in Route53 where the SSL certificates will be created | `string` | n/a | yes |
| <a name="input_string_schemas"></a> [string\_schemas](#input\_string\_schemas) | String schemas to include | <pre>list(object({<br/>    attribute_data_type = string<br/>    developer_only_attribute = bool<br/>    mutable = bool<br/>    name = string<br/>    required = bool<br/>    string_attribute_constraints = object({<br/>      min_length = number<br/>      max_length = number<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_domain_validation_options"></a> [acm\_certificate\_domain\_validation\_options](#output\_acm\_certificate\_domain\_validation\_options) | n/a |
| <a name="output_alternate_urls"></a> [alternate\_urls](#output\_alternate\_urls) | Alternate URLs of the website |
| <a name="output_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#output\_cognito\_user\_pool\_id) | ID of the Cognito user pool. |
| <a name="output_iam_access_key_id"></a> [iam\_access\_key\_id](#output\_iam\_access\_key\_id) | n/a |
| <a name="output_iam_access_key_secret"></a> [iam\_access\_key\_secret](#output\_iam\_access\_key\_secret) | n/a |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket |
| <a name="output_url"></a> [url](#output\_url) | URL of the main website |
| <a name="output_user_arn"></a> [user\_arn](#output\_user\_arn) | the arn of the user that was created |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | the name of the service account user that was created |
<!-- END_TF_DOCS -->
