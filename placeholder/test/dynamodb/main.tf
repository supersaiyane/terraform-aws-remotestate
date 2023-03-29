resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  count = length(var.dynamodB_table_names)
  name = var.dynamodB_table_names[count.index]
  hash_key = "LockID"
  billing_mode  = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}