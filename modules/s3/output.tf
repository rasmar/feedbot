output "bucket_id" {
  value = "${aws_s3_bucket.feedbot_bucket.id}"
}
output "s3_key" {
  value = "${aws_s3_bucket_object.code_pack.key}"
}

output "s3_etag" {
  value = "${aws_s3_bucket_object.code_pack.etag}"
}
