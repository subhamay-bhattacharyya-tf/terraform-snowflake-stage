# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Main
# -----------------------------------------------------------------------------
# Creates and manages Snowflake stages based on the stage_configs map.
# Uses snowflake_internal_stage for internal stages and
# snowflake_external_stage_s3 for S3 external stages.
# -----------------------------------------------------------------------------

locals {
  internal_stages = { for k, v in var.stage_configs : k => v if v.url == null }
  external_stages = { for k, v in var.stage_configs : k => v if v.url != null }
}

# Internal Stages (Snowflake-managed storage)
resource "snowflake_internal_stage" "this" {
  for_each = local.internal_stages

  name     = each.value.name
  database = each.value.database
  schema   = each.value.schema

  # File format
  file_format = each.value.file_format

  # Copy options
  copy_options = each.value.copy_options

  # Directory table settings
  directory = each.value.directory

  # Encryption settings
  encryption = each.value.encryption

  comment = each.value.comment
}

# External Stages (S3)
resource "snowflake_external_stage_s3" "this" {
  for_each = local.external_stages

  name     = each.value.name
  database = each.value.database
  schema   = each.value.schema

  # External stage URL
  url = each.value.url

  # Storage integration for external stages
  storage_integration = each.value.storage_integration

  # Credentials for external stages (when not using storage integration)
  credentials = each.value.credentials

  # File format
  file_format = each.value.file_format

  # Copy options
  copy_options = each.value.copy_options

  # Directory table settings
  directory = each.value.directory

  # Encryption settings
  encryption = each.value.encryption

  comment = each.value.comment
}
