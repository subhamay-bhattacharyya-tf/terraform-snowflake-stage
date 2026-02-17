# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Internal Stage Example
# -----------------------------------------------------------------------------
# This example demonstrates how to use the snowflake-stage module to create
# internal Snowflake stages (Snowflake-managed storage).
# -----------------------------------------------------------------------------

module "stage" {
  source = "../../"

  stage_configs = var.stage_configs
}
