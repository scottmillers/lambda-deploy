variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  default = "lambda-url-to-html"
}

variable "lambda_live_alias_name" {
  default = "live"
}

variable "lambda_latest_alias_name" {
  default = "latest"
}


variable "bucket_name" {
  default = "storage-for-lambda-url-to-html"
}
