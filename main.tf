provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "dynamodb" {
  source = "modules/dynamodb"
}

module "s3" {
  source = "modules/s3"
}
module "lambdas" {
  source                   = "modules/lambdas"
  slack_bot_token          = "${var.slack_bot_token}"
  slack_oauth_token        = "${var.slack_oauth_token}"
  slack_leader_label_id    = "${var.slack_leader_label_id}"
  salesforce_client_secret = "${var.salesforce_client_secret}"
  salesforce_client_key    = "${var.salesforce_client_key}"
  dynamodb_arn             = "${module.dynamodb.arn}"
  s3_bucket                = "${module.s3.bucket_id}"
}
module "api_gateway" {
  source          = "modules/api_gateway"
  feedbot_sc_name = "${module.lambdas.feedbot_sc_name}"
  feedbot_sc_arn  = "${module.lambdas.feedbot_sc_arn}"
  feedbot_sm_name = "${module.lambdas.feedbot_sm_name}"
  feedbot_sm_arn  = "${module.lambdas.feedbot_sm_arn}"
  aws_region      = "${var.aws_region}"
}

resource "local_file" "output_values" {
    content = "{\n  \"api_gateway_invoke_url\": \"${module.api_gateway.invoke_url}\"\n}"
    filename = "output.json"
}
