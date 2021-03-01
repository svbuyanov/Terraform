provider "aws" {
  profile = "virtualhealth"
  alias = "virtualhealth"
  region  = "us-east-1"
  version = "~> 2.70"
}

resource "aws_s3_bucket" "vh_backup_aws_s3_bucket" {
  bucket = "vh-${lower(var.client_name)}-backup"
  acl    = "private"
  region = var.aws_region
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id = "backup"
    prefix = ""
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days = 60
      storage_class = "GLACIER"
    }
    noncurrent_version_transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
    noncurrent_version_transition {
      days = 60
      storage_class = "GLACIER"
    }
  }
  tags = {
    Terraform   = "true"
    client      = var.client_name
    type        = "backup"
    service     = "s3"
    data        = "sensitive"
  }
}


data "aws_iam_policy_document" "vh_backup_s3_iam_policy_document" {
  # Policy statements
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.vh_backup_aws_s3_bucket.arn,
      "${aws_s3_bucket.vh_backup_aws_s3_bucket.arn}/*"
    ]
    principals {
        type = "AWS"
        identifiers = [
            "arn:aws:iam::462651409948:user/s3sync"
        ]
    }
  }
}

resource "aws_s3_bucket_policy" "vh_backup_aws_s3_bucket_policy" {
  bucket = aws_s3_bucket.vh_backup_aws_s3_bucket.id
  policy = data.aws_iam_policy_document.vh_backup_s3_iam_policy_document.json
}

resource "aws_s3_bucket_public_access_block" "vh_backup_bucket_aws_s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.vh_backup_aws_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "vh_backup_aws_iam_user" {
  name = "vh-${var.client_name}-backup"
  tags = {
    Terraform   = "true"
    client      = var.client_name
    type        = "backup"
    service     = "s3"
    data        = "sensitive"
  }
}

resource "aws_iam_access_key" "vh_backup_aws_iam_access_key" {
  user = aws_iam_user.vh_backup_aws_iam_user.name
}

resource "aws_iam_user_policy" "vh_backup_aws_iam_user_policy" {
  name   = "vh-${var.client_name}-backup"
  user   = aws_iam_user.vh_backup_aws_iam_user.name
  policy = data.aws_iam_policy_document.vh_backup_aws_iam_policy_document.json
}

data "aws_iam_policy_document" "vh_backup_aws_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      aws_s3_bucket.vh_backup_aws_s3_bucket.arn,
      "${aws_s3_bucket.vh_backup_aws_s3_bucket.arn}/*"
    ]
  }
}

#this is needed for loading backups to mysql-shared-db instance for deident/decrypt processes
resource "aws_iam_user_policy" "vh_backup_s3sync_aws_iam_user_policy" {
  provider = aws.virtualhealth
  name   = "vh-${var.client_name}-backup-s3sync"
  user   = "s3sync"
  policy = data.aws_iam_policy_document.vh_backup_s3sync_aws_iam_policy_document.json
}

data "aws_iam_policy_document" "vh_backup_s3sync_aws_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.vh_backup_aws_s3_bucket.arn,
      "${aws_s3_bucket.vh_backup_aws_s3_bucket.arn}/*"
    ]
  }
}
