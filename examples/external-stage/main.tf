# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - External Stage Example
# -----------------------------------------------------------------------------
# This example demonstrates how to use the snowflake-stage module to create
# external Snowflake stages pointing to cloud storage (S3, GCS, Azure).
# -----------------------------------------------------------------------------

module "stage" {
  source = "../../"

  stage_configs = var.stage_configs
}
