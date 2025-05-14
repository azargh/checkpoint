# creates the S3 bucket

resource "aws_s3_bucket" "CheckPointBucket" {
  bucket = "checkpoint-hw-2"
}