# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Multiple Stages Example
# -----------------------------------------------------------------------------
# This example demonstrates how to use the snowflake-stage module to create
# multiple stages of different types (internal and external) in a single call.
# -----------------------------------------------------------------------------

module "stages" {
  source = "../../"

  stage_configs = var.stage_configs
}
