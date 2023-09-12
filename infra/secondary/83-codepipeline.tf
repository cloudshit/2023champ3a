resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = "skills-artifacts-ap"
  force_destroy = true
}

output ap_codepipeline_bucket {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}
