# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Outputs
# -----------------------------------------------------------------------------
# Output values for the Snowflake stage module.
# -----------------------------------------------------------------------------

output "stage_names" {
  description = "The names of the created stages."
  value = merge(
    { for k, v in snowflake_stage_internal.this : k => v.name },
    { for k, v in snowflake_stage_external_s3.this : k => v.name }
  )
}

output "stage_fully_qualified_names" {
  description = "The fully qualified names of the stages."
  value = merge(
    { for k, v in snowflake_stage_internal.this : k => v.fully_qualified_name },
    { for k, v in snowflake_stage_external_s3.this : k => v.fully_qualified_name }
  )
}

output "stage_databases" {
  description = "The databases containing the stages."
  value = merge(
    { for k, v in snowflake_stage_internal.this : k => v.database },
    { for k, v in snowflake_stage_external_s3.this : k => v.database }
  )
}

output "stage_schemas" {
  description = "The schemas containing the stages."
  value = merge(
    { for k, v in snowflake_stage_internal.this : k => v.schema },
    { for k, v in snowflake_stage_external_s3.this : k => v.schema }
  )
}

output "stage_urls" {
  description = "The URLs of external stages (null for internal stages)."
  value = merge(
    { for k, v in snowflake_stage_internal.this : k => null },
    { for k, v in snowflake_stage_external_s3.this : k => v.url }
  )
}

output "stage_types" {
  description = "The types of stages (INTERNAL or EXTERNAL)."
  value       = { for k, stage in var.stage_configs : k => stage.url != null ? "EXTERNAL" : "INTERNAL" }
}

output "internal_stages" {
  description = "All internal stage resources."
  value       = snowflake_stage_internal.this
}

output "external_stages" {
  description = "All external S3 stage resources."
  value       = snowflake_stage_external_s3.this
}
