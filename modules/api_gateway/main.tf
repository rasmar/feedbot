resource "aws_api_gateway_rest_api" "feedbot" {
  name        = "feedBot"
  description = "feedBot API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_lambda_permission" "lambdasc_permission" {
  statement_id  = "AllowLambdaSCExecution"
  action        = "lambda:InvokeFunction"
  function_name = "${var.feedbot_sc_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.feedbot.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "lambdasm_permission" {
  statement_id  = "AllowLambdaSMExecution"
  action        = "lambda:InvokeFunction"
  function_name = "${var.feedbot_sm_name}"
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
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.feedbot_sc_arn}/invocations"

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
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.feedbot_sm_arn}/invocations"
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
