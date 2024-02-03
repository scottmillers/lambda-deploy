provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

}


/*
  This module creates an S3 bucket for storing objects used by the Lambda function "url-to-html".
  The bucket is configured public access and has a bucket policy that allows public anonymous read-only 
  access.  Versioning is enabled for the bucket, and it can be forcefully destroyed even if it has objects.
*/
module "bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket                   = var.bucket_name
  acl                      = "public-read"
  restrict_public_buckets  = false # Make it public
  ignore_public_acls       = false # Make it public
  block_public_acls        = false # Make it public
  block_public_policy      = false # Make it public
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true # delete the bucket even if it has objects

  versioning = {
    enabled = true
  }
  attach_policy = true # attach the below
  policy        = <<-EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
EOF

}



/*
  This module creates an AWS Lambda function that converts a URL to HTML content.
  Timeout is increase to 20 seconds to allow time to access web page and store them in S3
*/
module "lambda" {
  source                   = "terraform-aws-modules/lambda/aws"
  version                  = "~> 7.0.0"
  function_name            = var.lambda_function_name
  handler                  = "index.handler"
  runtime                  = "nodejs20.x"
  timeout                  = 20
  create_package           = false
  local_existing_package   = "src/deploy/latest.zip"
  attach_policy_statements = true
  policy_statements = {
    s3_allow_all = {
      effect    = "Allow",
      actions   = ["s3:*", "s3-object-lambda:*"],
      resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    }
  }
}

/*
  This module creates an AWS Lambda function that converts a URL to HTML content.
*/
module "live_alias" {
  source           = "terraform-aws-modules/lambda/aws//modules/alias"
  refresh_alias    = false
  name             = var.lambda_live_alias_name
  function_name    = module.lambda.lambda_function_name
  function_version = module.lambda.lambda_function_version

}

module "latest_alias" {
  source           = "terraform-aws-modules/lambda/aws//modules/alias"
  refresh_alias    = false
  name             = var.lambda_latest_alias_name
  function_name    = module.lambda.lambda_function_name
  function_version = module.lambda.lambda_function_version
}

resource "aws_lambda_function_url" "live_url" {
  function_name      = module.lambda.lambda_function_name
  authorization_type = "NONE"
  qualifier          = var.lambda_live_alias_name
}

resource "aws_lambda_function_url" "latest_url" {
  function_name      = module.lambda.lambda_function_name
  authorization_type = "NONE"
  qualifier          = var.lambda_latest_alias_name
}







