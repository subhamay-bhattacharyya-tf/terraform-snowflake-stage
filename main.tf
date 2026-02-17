# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Main
# -----------------------------------------------------------------------------
# Creates and manages Snowflake stages based on the stage_configs map.
# Uses snowflake_stage_internal for internal stages and
# snowflake_stage_external_s3 for S3 external stages.
# -----------------------------------------------------------------------------

locals {
  internal_stages = { for k, v in var.stage_configs : k => v if v.url == null }
  external_stages = { for k, v in var.stage_configs : k => v if v.url != null }
}

# Internal Stages (Snowflake-managed storage)
resource "snowflake_stage_internal" "this" {
  for_each = local.internal_stages

  name     = each.value.name
  database = each.value.database
  schema   = each.value.schema

  comment = each.value.comment
}

# External Stages (S3)
resource "snowflake_stage_external_s3" "this" {
  for_each = local.external_stages

  name     = each.value.name
  database = each.value.database
  schema   = each.value.schema

  # External stage URL
  url = each.value.url

  # Storage integration for external stages
  storage_integration = each.value.storage_integration

  comment = each.value.comment
}
