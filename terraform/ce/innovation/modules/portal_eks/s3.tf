resource "random_id" "id" {
  byte_length = 2
}

# S3 bucket for remote Terraform backend
resource "aws_s3_bucket" "bucket" {
  bucket = "ce-innovation-formio-service-${random_id.id.hex}"
  object_lock_configuration {
    object_lock_enabled = "Enabled"
  }
  tags = {
    Name = "S3 bucket for formio pdf server"
  }
}

resource "aws_s3_bucket_versioning" "version_configuration" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
