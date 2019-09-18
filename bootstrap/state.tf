resource "aws_dynamodb_table" "state" {
  name           = "${var.project}-state"
  read_capacity  = "20"
  write_capacity = "20"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project}-state"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "${var.project}-state"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = "${aws_s3_bucket.state.id}"

  block_public_acls   = true
  block_public_policy = true
}
