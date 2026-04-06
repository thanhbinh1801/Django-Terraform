resource "aws_s3_bucket" "django_assets" {
  bucket        = "${var.project_name}-assets-bucket-1801"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.django_assets.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
