resource "aws_dynamodb_table" "feedbot-table" {
  name           = "Feedbot"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }

  attribute {
    name = "AskedId"
    type = "S"
  }

  attribute {
    name = "Status"
    type = "S"
  }

  attribute {
    name = "RequesterId"
    type = "S"
  }

  attribute {
    name = "TargetId"
    type = "S"
  }

  global_secondary_index {
    name               = "AskedId-Status-index"
    hash_key           = "AskedId"
    range_key          = "Status"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = [
      "RequesterId", "Message", "TargetId", "Deadline", "ActionId" 
    ]
  }


  global_secondary_index {
    name               = "RequesterId-TargetId-index"
    hash_key           = "RequesterId"
    range_key          = "TargetId"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = [
      "AskedId", "Deadline", "Status"
    ]
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags {
    Project = "feedbot"
  }
}
