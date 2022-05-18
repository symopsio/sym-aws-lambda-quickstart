provider "aws" {
  region = var.aws_region
}

provider "sym" {
  org = var.sym_org_slug
}

# Example Lambda function that can integrate with Sym.
module "my_lambda" {
  source = "../../modules/my-lambda"

  tags = var.tags
}

# A Sym Runtime that executes your Flows.
module "sym_runtime" {
  source = "../../modules/sym-runtime"

  error_channel      = var.error_channel
  runtime_name       = var.runtime_name
  slack_workspace_id = var.slack_workspace_id
  sym_account_ids    = var.sym_account_ids
  tags               = var.tags
}

# A Flow that invokes your example Lambda function.
module "lambda_flow" {
  source = "../../modules/lambda-flow"

  flow_vars        = var.flow_vars
  lambda_arn       = module.my_lambda.lambda_arn
  runtime_settings = module.sym_runtime.runtime_settings
  sym_environment  = module.sym_runtime.environment
  tags             = var.tags
}
