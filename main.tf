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
module "lambdasc" {
  source  = "crisboarna/lambda-invoke/aws"
  version = "0.3.0"

  #Global
  region = "${var.aws_region}"

  #Lambda
  lambda_function_name               = "feedBot-sc"
  lambda_description                 = "feedBot slack component lambda"
  lambda_runtime                     = "ruby2.5"
  lambda_handler                     = "handlers/slack_component.FeedBot::Handler::SlackComponent.handle"
  lambda_timeout                     = 30
  lambda_code_s3_bucket_use_existing = "true"
  lambda_code_s3_bucket_existing     = "${module.s3_bucket.bucket_id}"
  lambda_code_s3_key                 = "source.zip"
  lambda_zip_path                    = "temp/source.zip"
  lambda_memory_size                 = 128
  lambda_policy_action_list          = ["dynamodb:*", "lamdba:InvokeFunction", "lambda:InvokeAsync"]
  lambda_policy_arn_list             = ["${aws_api_gateway_rest_api.feedbot.execution_arn}"]

  #Lambda Environment variables
  environmentVariables = {
    SLACK_BOT_TOKEN          = "${var.slack_bot_token}"
    SLACK_OAUTH_TOKEN        = "${var.slack_oauth_token}"
    SLACK_LEADER_LABEL_ID    = "${var.slack_leader_label_id}"
    SALESFORCE_CLIENT_SECRET = "${var.salesforce_client_secret}"
    SALESFORCE_CLIENT_KEY    = "${var.salesforce_client_key}"
  }
}
module "lambdasm" {
  source  = "crisboarna/lambda-invoke/aws"
  version = "0.3.0"

  #Global
  region = "${var.aws_region}"

  #Lambda
  lambda_function_name               = "feedBot-sm"
  lambda_description                 = "feedBot slack message lambda"
  lambda_runtime                     = "ruby2.5"
  lambda_handler                     = "handlers/slack_message.FeedBot::Handler::SlackMessage.handle"
  lambda_timeout                     = 30
  lambda_code_s3_bucket_use_existing = "true"
  lambda_code_s3_bucket_existing     = "${module.s3_bucket.bucket_id}"
  lambda_code_s3_key                 = "source.zip"
  lambda_zip_path                    = "temp/source.zip"
  lambda_memory_size                 = 128
  lambda_policy_action_list          = ["dynamodb:*", "lamdba:InvokeFunction", "lambda:InvokeAsync"]
  lambda_policy_arn_list             = ["${aws_api_gateway_rest_api.feedbot.execution_arn}"]

  #Lambda Environment variables
  environmentVariables = {
    SLACK_BOT_TOKEN          = "${var.slack_bot_token}"
    SLACK_OAUTH_TOKEN        = "${var.slack_oauth_token}"
    SLACK_LEADER_LABEL_ID    = "${var.slack_leader_label_id}"
    SALESFORCE_CLIENT_SECRET = "${var.salesforce_client_secret}"
    SALESFORCE_CLIENT_KEY    = "${var.salesforce_client_key}"
  }
}
resource "aws_lambda_permission" "lambdasc_permission" {
  statement_id  = "AllowLambdaSCExecution"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambdasc.lambda_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.feedbot.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "lambdasm_permission" {
  statement_id  = "AllowLambdaSMExecution"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambdasm.lambda_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.feedbot.execution_arn}/*/*/*"
}
resource "aws_api_gateway_resource" "slack_component" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.feedbot.root_resource_id}"
  path_part   = "slack_component"
}
resource "aws_api_gateway_resource" "slack_message" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.feedbot.root_resource_id}"
  path_part   = "slack_message"
}
resource "aws_api_gateway_method" "slack_component_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id   = "${aws_api_gateway_resource.slack_component.id}"
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "slack_message_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id   = "${aws_api_gateway_resource.slack_message.id}"
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "slack_component_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id             = "${aws_api_gateway_resource.slack_component.id}"
  http_method             = "${aws_api_gateway_method.slack_component_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambdasc.lambda_arn}/invocations"

  request_templates = {
    "application/x-www-form-urlencoded" = <<JSON
{
  "body": $input.json('$')
}
JSON
  }
}
resource "aws_api_gateway_integration" "slack_message_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id             = "${aws_api_gateway_resource.slack_message.id}"
  http_method             = "${aws_api_gateway_method.slack_message_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambdasm.lambda_arn}/invocations"
}
resource "aws_api_gateway_method_response" "slack_component_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack_component.id}"
  http_method = "${aws_api_gateway_method.slack_component_post.http_method}"
  status_code = "200"
  response_models = { "application/json" = "Empty" }
}
resource "aws_api_gateway_method_response" "slack_message_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack_message.id}"
  http_method = "${aws_api_gateway_method.slack_message_post.http_method}"
  status_code = "200"
  response_models = { "application/json" = "Empty" }
}
resource "aws_api_gateway_integration_response" "slack_component_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack_component.id}"
  http_method = "${aws_api_gateway_method.slack_component_post.http_method}"
  status_code = "${aws_api_gateway_method_response.slack_component_response.status_code}"
  response_templates { "application/json" = "" }
  depends_on = [
    "aws_api_gateway_integration.slack_component_integration"
  ]
}
resource "aws_api_gateway_integration_response" "slack_message_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  resource_id = "${aws_api_gateway_resource.slack_message.id}"
  http_method = "${aws_api_gateway_method.slack_message_post.http_method}"
  status_code = "${aws_api_gateway_method_response.slack_message_response.status_code}"
  response_templates { "application/json" = "" }
  depends_on = [
    "aws_api_gateway_integration.slack_message_integration"
  ]
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.slack_component_integration",
    "aws_api_gateway_integration_response.slack_component_integration_response",
    "aws_api_gateway_integration.slack_message_integration",
    "aws_api_gateway_integration_response.slack_message_integration_response"
    ]

  rest_api_id = "${aws_api_gateway_rest_api.feedbot.id}"
  stage_name  = "prod"
}

resource "local_file" "output_values" {
    content = "{\n  \"api_gateway_invoke_url\": \"${aws_api_gateway_deployment.api_deployment.invoke_url}\"\n}"
    filename = "output.json"
}
