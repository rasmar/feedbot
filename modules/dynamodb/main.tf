resource "aws_dynamodb_table" "feedbot-table" {
  name           = "Feedbot"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "RequestId"
  range_key      = "Requester"

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "Requester"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags {
    Project = "feedbot"
  }
}
