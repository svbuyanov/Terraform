output "vh_upload_aws_iam_access_key_secret" {
  value = aws_iam_access_key.vh_backup_aws_iam_access_key.secret
}

output "vh_upload_aws_iam_access_key_id" {
  value = aws_iam_access_key.vh_backup_aws_iam_access_key.id
}

output "vh_upload_aws_s3_bucket_id"{
  value = aws_s3_bucket.vh_backup_aws_s3_bucket.id
}
