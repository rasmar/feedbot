resource "aws_lambda_function" "feedbot_sm" {
  function_name    = "feedbotsm"
  role             = "${aws_iam_role.feedbot_role.arn}"
  handler          = "handlers/slack_message.FeedBot::Handler::SlackMessage.handle"
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${var.s3_key}"
  runtime          = "ruby2.5"
  timeout          = 30
  description      = "feedBot slack component lambda"
  source_code_hash = "${var.s3_etag}"

  environment {
    variables = {
      SLACK_BOT_TOKEN          = "${var.slack_bot_token}"
      SLACK_OAUTH_TOKEN        = "${var.slack_oauth_token}"
      SLACK_LEADER_LABEL_ID    = "${var.slack_leader_label_id}"
      SALESFORCE_CLIENT_SECRET = "${var.salesforce_client_secret}"
      SALESFORCE_CLIENT_KEY    = "${var.salesforce_client_key}"
      AWS_DYNAMODB_ARN         = "${var.dynamodb_arn}"
    }
  }

  tags {
    Project = "feedbot"
  }

  depends_on = ["aws_iam_role.feedbot_role", "aws_iam_role_policy_attachment.feedbot", "aws_cloudwatch_log_group.feedbot_sm_logs"]
}

resource "aws_lambda_function" "feedbot_sc" {
  function_name    = "feedbotsc"
  role             = "${aws_iam_role.feedbot_role.arn}"
  handler          = "handlers/slack_message.FeedBot::Handler::SlackComponent.handle"
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${var.s3_key}"
  runtime          = "ruby2.5"
  timeout          = 30
  description      = "feedBot slack component lambda"
  source_code_hash = "${var.s3_etag}"

  environment {
    variables = {
      SLACK_BOT_TOKEN          = "${var.slack_bot_token}"
      SLACK_OAUTH_TOKEN        = "${var.slack_oauth_token}"
      SLACK_LEADER_LABEL_ID    = "${var.slack_leader_label_id}"
      SALESFORCE_CLIENT_SECRET = "${var.salesforce_client_secret}"
      SALESFORCE_CLIENT_KEY    = "${var.salesforce_client_key}"
      AWS_DYNAMODB_ARN         = "${var.dynamodb_arn}"
    }
  }

  tags {
    Project = "feedbot"
  }

  depends_on = ["aws_lambda_function.feedbot_sm", "aws_cloudwatch_log_group.feedbot_sc_logs"]
}

resource "aws_iam_role" "feedbot_role" {
  name = "feedbot_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "feedbot_sm_logs" {
  name              = "/aws/lambda/feedbotsm"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "feedbot_sc_logs" {
  name              = "/aws/lambda/feedbotsc"
  retention_in_days = 14
}

resource "aws_iam_policy" "feedbot_policy" {
  name = "feedbot_policy"
  path = "/"
  description = "IAM policy for Feedbot"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": "dynamodb:*",
      "Resource": "${var.dynamodb_arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "feedbot" {
  role = "${aws_iam_role.feedbot_role.name}"
  policy_arn = "${aws_iam_policy.feedbot_policy.arn}"
}
