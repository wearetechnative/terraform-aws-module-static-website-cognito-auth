resource "random_pet" "this" {
  length = 1
}

module "website_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket                  = "${var.domain}-${random_pet.this.id}"
  force_destroy           = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true

  versioning = {
    enabled = true
  }
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
  name = "${var.deploy_user_name}"
}

resource "aws_iam_access_key" "user_keys" {
  user = "${aws_iam_user.user.name}"
}

resource "aws_s3_bucket_policy" "bucket_policy_web" {
  bucket = module.website_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
