resource "aws_s3_bucket" "rugged_buckets" {
  count         = length(var.s3_bucket_names) //count will be 3
  bucket        = var.s3_bucket_names[count.index]
  #acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "s3acl" {
  count = length(var.s3_bucket_names)
  bucket = aws_s3_bucket.rugged_buckets[count.index].id
  #bucket = flatten([aws_s3_bucket.rugged_buckets.*.id])
  acl = "private"
}

resource "aws_s3_bucket_ownership_controls" "s3Ownership" {
  count = length(var.s3_bucket_names)
  bucket = aws_s3_bucket.rugged_buckets[count.index].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "s3Versioning" {
  count = length(var.s3_bucket_names)
  bucket = aws_s3_bucket.rugged_buckets[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3PublicBlock" {
  count = length(var.s3_bucket_names)
  bucket = aws_s3_bucket.rugged_buckets[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}