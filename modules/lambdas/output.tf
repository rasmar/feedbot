output "feedbot_sm_arn" {
  value = "${aws_lambda_function.feedbot_sm.arn}"
}
output "feedbot_sm_name" {
  value = "${aws_lambda_function.feedbot_sm.function_name}"
}

output "feedbot_sc_arn" {
  value = "${aws_lambda_function.feedbot_sc.arn}"
}
output "feedbot_sc_name" {
  value = "${aws_lambda_function.feedbot_sc.function_name}"
}
