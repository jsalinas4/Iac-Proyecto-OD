resource "aws_s3_bucket" "b" {
  bucket = "bucket-frontend"

  tags = {
    Name = "Bucket S3 Frontend de Proyecto"
  }
}

data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.b.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}
