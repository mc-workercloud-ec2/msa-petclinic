
resource "aws_s3_bucket" "loki" {
  bucket        = "loki-bucket-2412-ec2team-${var.environment}"
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}
resource "aws_s3_bucket_policy" "cdn_allow" {
  bucket = aws_s3_bucket.loki.id
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "DenyPutObjectUnlessVpceIsUsed",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.loki.bucket}/*",
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpce": "${var.s3_endpoint}"
        }
      }
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "loki_assume_role" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"

      identifiers = [
        "${var.oidc_arn}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc}:sub"
      values   = ["system:serviceaccount:loki:loki"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "loki_role" {
  name               = "loki-role"
  assume_role_policy = data.aws_iam_policy_document.loki_assume_role.json
}

data "aws_iam_policy_document" "loki_s3_policy_doc" {
  version = "2012-10-17"

  statement {
    sid    = "LokiStorage"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.loki.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.loki.bucket}/*",

    ]
  }
}

resource "aws_iam_policy" "loki_s3_policy" {
  name   = "loki-s3-policy"
  policy = data.aws_iam_policy_document.loki_s3_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "loki_s3_policy_attach" {
  role       = aws_iam_role.loki_role.name
  policy_arn = aws_iam_policy.loki_s3_policy.arn
}