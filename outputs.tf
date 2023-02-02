locals {
  url = "https://${var.domain}"
}

output "url" {
  description = "URL of the main website"
  value       = local.url
}

output "alternate_urls" {
  description = "Alternate URLs of the website"
  value       = formatlist("https://%s", var.domain_aliases)
}

output "s3_bucket_id" {
  description = "The name of the bucket"
  value       = module.website_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.website_bucket.s3_bucket_arn
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool."
  value       = module.cognito-user-pool.id
}

output "user_arn" {
  description = "the arn of the user that was created"
  value = aws_iam_user.user.arn
}

output "user_name" {
  description = "the name of the service account user that was created"
  value = aws_iam_user.user.name
}
output "iam_access_key_id" {
  value = aws_iam_access_key.user_keys.id
}

output "iam_access_key_secret" {
  value = aws_iam_access_key.user_keys.secret
}


