variable "function_name" {
  description = "Name of the Lambda function to create"
  default     = "sym-lambda-example"
}

variable "s3_bucket" {
  description = "S3 Bucket with the lambda code"
  default     = "sym-releases"
}

variable "s3_key" {
  description = "S3 Key with the path to the lambda code"
  default     = "lambda-templates/python.zip"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
