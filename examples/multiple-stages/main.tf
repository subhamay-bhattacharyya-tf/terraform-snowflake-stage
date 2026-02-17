# Example: Multiple Snowflake Stages (Internal and External)
#
# This example demonstrates how to use the snowflake-stage module
# to create multiple stages of different types in a single module call.

module "stages" {
  source = "../../"

  stage_configs = var.stage_configs
}
