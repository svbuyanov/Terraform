
resource "aws_s3_bucket" "vh_upload_aws_s3_bucket" {
  bucket = "vh-${lower(var.client_name)}-${lower(var.client_env)}-upload"
  acl    = "private"
  region = var.aws_region
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  tags = {
    Client      = var.client_name
    Environment = var.client_env
  }
}

resource "aws_s3_bucket_public_access_block" "vh_upload_bucket_aws_s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.vh_upload_aws_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "vh_upload_aws_iam_user" {
  name = "vh-${var.client_name}-${var.client_env}-upload"
  tags = {
    Client      = var.client_name
    Environment = var.client_env
  }
}

resource "aws_iam_access_key" "vh_upload_aws_iam_access_key" {
  user = aws_iam_user.vh_upload_aws_iam_user.name
}

resource "aws_iam_user_policy" "vh_upload_aws_iam_user_policy" {
  name   = "vh-${var.client_name}-${var.client_env}-upload"
  user   = aws_iam_user.vh_upload_aws_iam_user.name
  policy = data.aws_iam_policy_document.vh_upload_aws_iam_policy_document.json
}

data "aws_iam_policy_document" "vh_upload_aws_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionTagging",
      "s3:ReplicateObject",
      "s3:GetObjectAcl",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetObjectVersionAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:GetBucketPolicyStatus",
      "s3:GetObjectRetention",
      "s3:GetBucketWebsite",
      "s3:DeleteObjectVersionTagging",
      "s3:PutObjectLegalHold",
      "s3:GetObjectLegalHold",
      "s3:GetBucketNotification",
      "s3:GetReplicationConfiguration",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetAnalyticsConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetLifecycleConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetBucketTagging",
      "s3:DeleteObjectVersion",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ReplicateTags",
      "s3:RestoreObject",
      "s3:ListBucket",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetEncryptionConfiguration",
      "s3:GetObjectVersionTorrent",
      "s3:AbortMultipartUpload",
      "s3:GetBucketRequestPayment",
      "s3:GetObjectTagging",
      "s3:GetMetricsConfiguration",
      "s3:GetBucketPublicAccessBlock",
      "s3:ListBucketMultipartUploads",
      "s3:PutObjectVersionTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetObjectTorrent",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:ReplicateDelete",
      "s3:GetObjectVersion",
      "s3:ListBucketByTags"
    ]
    resources = [
      aws_s3_bucket.vh_upload_aws_s3_bucket.arn,
      "${aws_s3_bucket.vh_upload_aws_s3_bucket.arn}/*"
    ]
  }
}
