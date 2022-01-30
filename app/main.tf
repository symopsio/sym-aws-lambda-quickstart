provider "aws" {
  region = var.aws_region
}

# Example Lambda integration with Sym
module "example_lambda" {
  source = "../modules/example-lambda"

  tags = var.tags
}
