provider "aws" {
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE"
  region     = "eu-central-1"
}

module "s3-bucket" {
  source                   = "cloudposse/s3-bucket/aws"
  version                  = "0.3.0"
  enabled                  = "${var.enabled}"
  user_enabled             = "${var.user_enabled}"
  versioning_enabled       = "${var.versioning_enabled}"
  allowed_bucket_actions   = "${var.allowed_bucket_actions}"
  name                     = "${var.name}"
  stage                    = "${var.stage}"
  namespace                = "${var.namespace}"
}