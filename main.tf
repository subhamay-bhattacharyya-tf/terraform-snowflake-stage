# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Main
# -----------------------------------------------------------------------------
# Creates and manages one or more Snowflake stages based on the stage_configs
# map. Supports both internal and external stages (S3, GCS, Azure).
# -----------------------------------------------------------------------------

resource "snowflake_stage" "this" {
  for_each = var.stage_configs

  name     = each.value.name
  database = each.value.database
  schema   = each.value.schema

  # External stage URL (S3, GCS, or Azure)
  url = each.value.url

  # Storage integration for external stages
  storage_integration = each.value.storage_integration

  # Credentials for external stages (when not using storage integration)
  credentials = each.value.credentials

  # Encryption settings
  encryption = each.value.encryption

  # File format
  file_format = each.value.file_format

  # Copy options
  copy_options = each.value.copy_options

  # Directory table settings (for directory-enabled stages)
  directory = each.value.directory

  comment = each.value.comment
}
