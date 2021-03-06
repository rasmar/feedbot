resource "aws_s3_bucket" "feedbot_bucket" {
  bucket = "netguru-feedbot"

  lifecycle_rule {
    id      = "expire"
    enabled = true
    prefix  = ""

    expiration {
      days = 14
    }
  }

  tags {
    Project = "feedbot"
  }
}

resource "aws_s3_bucket_object" "code_pack" {
  bucket = "${aws_s3_bucket.feedbot_bucket.id}"
  key    = "source.zip"
  source = "temp/source.zip"
  etag   = "${md5(file("temp/source.zip"))}"
}
