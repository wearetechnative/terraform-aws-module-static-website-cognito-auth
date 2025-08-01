resource "random_pet" "this" {
  length = 1
}

module "website_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.2.0"

  bucket                  = "${var.domain}-${random_pet.this.id}"
  force_destroy           = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true

  object_ownership = "BucketOwnerEnforced"
  control_object_ownership = true

  versioning = {
    status = true
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_web" {
  bucket = module.website_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policies.json
}

data "aws_iam_policy_document" "s3_policies" {
  source_policy_documents = concat([ data.aws_iam_policy_document.s3_policy.json ]
  , var.bucket_policy_addition != null ? [jsonencode({
      "Statement" : [for v in var.bucket_policy_addition.Statement : merge(v, { "Resource" : [for s in flatten(concat([v.Resource], [])) : replace(s, "<bucket>", module.website_bucket.s3_bucket_arn)] })]
      "Version" : lookup(var.bucket_policy_addition, "Version", null) != null ? var.bucket_policy_addition.Version : "2012-10-17"
    })] : []
  )
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.website_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }

  statement {
    actions   = ["s3:*"]
    resources = [
      "${module.website_bucket.s3_bucket_arn}",
      "${module.website_bucket.s3_bucket_arn}/*"
     ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.user.arn]
    }
  }
}

resource "aws_iam_user" "user" {
  name = var.deploy_user_name
}

resource "aws_iam_access_key" "user_keys" {
  user = aws_iam_user.user.name
}
