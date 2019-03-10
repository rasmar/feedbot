provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
module "s3_bucket" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=master"
  version                  = "0.3.0"
  enabled                  = "true"
  user_enabled             = "false"
  versioning_enabled       = "false"
  allowed_bucket_actions   = []
  name                     = "feedbot"
  stage                    = "prod"
  namespace                = "co"
}
resource "aws_s3_bucket_object" "code_pack" {
  bucket = "${module.s3_bucket.bucket_id}"
  key    = "source.zip"
  source = "temp/source.zip"
  etag   = "${md5(file("temp/source.zip"))}"
}
resource "aws_api_gateway_rest_api" "feedbot" {
  name        = "feedBot"
  description = "feedBot API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
module "lambda" {
  source  = "crisboarna/lambda-invoke/aws"
  version = "0.3.0"

  #Global
  region = "${var.aws_region}"

  #Lambda
  lambda_function_name               = "feedBot"
  lambda_description                 = "feedBot main lambda"
  lambda_runtime                     = "ruby2.5"
  lambda_handler                     = "main.interact"
  lambda_timeout                     = 30
  lambda_code_s3_bucket_use_existing = "true"
  lambda_code_s3_bucket_existing     = "${module.s3_bucket.bucket_id}"
  lambda_code_s3_key                 = "source.zip"
  lambda_zip_path                    = "temp/source.zip"
  lambda_memory_size                 = 128
  lambda_policy_action_list          = ["dynamodb:*"]
  lambda_policy_arn_list             = ["${aws_api_gateway_rest_api.feedbot.execution_arn}"]

  #Lambda Environment variables
  environmentVariables = {
    SLACK_ACCESS_TOKEN       = "${var.slack_access_token}"
    SALESFORCE_CLIENT_SECRET = "${var.salesforce_client_secret}"
    SALESFORCE_CLIENT_KEY    = "${var.salesforce_client_key}"
  }
}
resource "aws_api_gateway_resource" "slack" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.feedbot.root_resource_id}"
  path_part   = "slack"
}
resource "aws_api_gateway_method" "slack_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id   = "${aws_api_gateway_resource.slack.id}"
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "slack_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id             = "${aws_api_gateway_resource.slack.id}"
  http_method             = "${aws_api_gateway_method.slack_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambda.lambda_arn}/invocations"
}
resource "aws_api_gateway_method_response" "slack_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack.id}"
  http_method = "${aws_api_gateway_method.slack_post.http_method}"
  status_code = "200"
  response_models = { "application/json" = "Empty" }
}
resource "aws_api_gateway_integration_response" "slack_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack.id}"
  http_method = "${aws_api_gateway_method.slack_post.http_method}"
  status_code = "${aws_api_gateway_method_response.slack_response.status_code}"
  response_templates { "application/json" = "" }
  depends_on = [
    "aws_api_gateway_integration.slack_integration"
  ]
}
resource "aws_api_gateway_resource" "forms" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.feedbot.root_resource_id}"
  path_part   = "forms"
}
resource "aws_api_gateway_method" "forms_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id   = "${aws_api_gateway_resource.forms.id}"
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "forms_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id             = "${aws_api_gateway_resource.forms.id}"
  http_method             = "${aws_api_gateway_method.forms_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambda.lambda_arn}/invocations"
}
resource "aws_api_gateway_method_response" "forms_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.forms.id}"
  http_method = "${aws_api_gateway_method.forms_post.http_method}"
  status_code = "200"
  response_models = { "application/json" = "Empty" }
}
resource "aws_api_gateway_integration_response" "forms_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.forms.id}"
  http_method = "${aws_api_gateway_method.forms_post.http_method}"
  status_code = "${aws_api_gateway_method_response.forms_response.status_code}"
  response_templates { "application/json" = "" }
  depends_on = [
    "aws_api_gateway_integration.forms_integration"
  ]
}
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.forms_integration",
    "aws_api_gateway_integration_response.forms_integration_response",
    "aws_api_gateway_integration.slack_integration",
    "aws_api_gateway_integration_response.slack_integration_response"
    ]

  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  stage_name  = "prod"
}