resource "aws_s3_bucket" "static_website" {
  bucket = "${var.prefix}-react-static-website"

    lifecycle {
    prevent_destroy = false
  }

  tags = {
    Project = "${var.prefix}"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"}
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.static_website.bucket}/*"
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"}
        Action    = "s3:*"
        Resource  = [
          "arn:aws:s3:::${aws_s3_bucket.static_website.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.static_website.bucket}/*"
        ]
      },
    ]
  })
}