# S3 bucket for remote Terraform backend
resource "aws_s3_bucket" "bucket" {
    bucket = "ce-innovation-formio-terraform-state-backend"
    object_lock_configuration {
        object_lock_enabled = "Enabled"
    }
    tags = {
        Name = "S3 Remote Terraform State Store"
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

# DynamoDB table for Terraform state lock
resource "aws_dynamodb_table" "terraform-lock" {
    name           = "terraform-state"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}

#terraform {
#  backend "s3" {
#    bucket         = "ce-innovation-formio-terraform-state-backend"
#    key            = "dev/backend/terraform.tfstate"
#    region         = "ca-central-1"
#    dynamodb_table = "sverify-terraform-state"
#  }
#}
