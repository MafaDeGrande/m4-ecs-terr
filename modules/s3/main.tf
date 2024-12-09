module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket                   = var.bucket_name
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_object" "env_file" {
  bucket = module.s3_bucket.s3_bucket_id
  key    = ".env"
  source = "${path.cwd}/.env"
}

