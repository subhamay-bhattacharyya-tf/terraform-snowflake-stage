# Example: Internal Snowflake Stage
#
# This example demonstrates how to use the snowflake-stage module
# to create internal Snowflake stages for temporary data storage.

module "stage" {
  source = "../../modules/snowflake-stage"

  stage_configs = var.stage_configs
}
