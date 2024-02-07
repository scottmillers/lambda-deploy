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

variable "oidc_thumbprint" {
  description = "Server certificate thumbprint is the hex-encoded SHA-1 hash value of the X.509 certificate used by the domain where the OpenID Connect provider makes its keys available."
  default     = "1b511abead59c6ce207077c0bf0e0043b1382612"

}
