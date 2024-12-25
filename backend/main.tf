resource "aws_s3_bucket" "tfstat" {
  bucket        = var.bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "tfstat" {
  bucket = aws_s3_bucket.tfstat.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-log"
  force_destroy = true 
  tags = {
    Name        = "${var.bucket_name}-log"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.tfstat.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "logs/${var.bucket_name}"
}



resource "aws_dynamodb_table" "lock" {
  name = var.lock_table_name

  // The number of read units for this table
  read_capacity = 5

  // The number of write units for this table.
  write_capacity = 5

  // The attribute to use as the hash (partition) key.
  hash_key = "LockID"

  /*
    List of nested attribute definitions.
    Only required for hash_key and range_key attributes. Each attribute has two properties:
      name - (Required) The name of the attribute
      type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data
  */
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.lock_table_name
    Environment = var.environment
  }
}