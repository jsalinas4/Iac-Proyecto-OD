resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "bucket-frontend"

  tags = {
    Name = "Bucket del sitio web"
  }
}

data "aws_iam_policy_document" "frontend_bucket_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  policy = data.aws_iam_policy_document.frontend_bucket_policy.json
}

# Este archivo tiene un aporte personal sobreescrbiendo el archiv anterior, crea un bucket S3 
#para alojar archivos del sitio y permite que CloudFront acceda a ellos de forma segura.
