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

  # Directory table settings
  dynamic "directory" {
    for_each = each.value.directory_enabled ? [1] : []
    content {
      enable = true
    }
  }

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

  # Directory table settings
  dynamic "directory" {
    for_each = each.value.directory_enabled ? [1] : []
    content {
      enable = true
    }
  }

  comment = each.value.comment
}

# Grant privileges to account roles on stages
resource "snowflake_grant_privileges_to_account_role" "stage_grants" {
  for_each = {
    for grant in flatten([
      for stage_key, stage in var.stage_configs : [
        for g in lookup(stage, "grants", []) : {
          key        = "${stage_key}_${g.role_name}"
          role_name  = g.role_name
          privileges = g.privileges
          database   = stage.database
          schema     = stage.schema
          name       = stage.name
        }
      ]
    ]) : grant.key => grant
  }

  account_role_name = each.value.role_name
  privileges        = each.value.privileges

  on_schema_object {
    object_type = "STAGE"
    object_name = "\"${each.value.database}\".\"${each.value.schema}\".\"${each.value.name}\""
  }

  depends_on = [snowflake_stage_internal.this, snowflake_stage_external_s3.this]
}
