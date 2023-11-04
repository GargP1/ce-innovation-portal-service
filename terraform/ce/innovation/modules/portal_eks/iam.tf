resource "aws_iam_user" "formio-s3-user" {
  name = "formio-s3-user"
}

resource "aws_iam_policy" "formio-s3-iam-policy" {
  name        = "formio-s3"
  description = "IAM Policy for formio to read and write to the S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "formio-s3-iam-policy-attachement" {
  user       = aws_iam_user.formio-s3-user.name
  policy_arn = aws_iam_policy.formio-s3-iam-policy.arn
}
