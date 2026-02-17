# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Outputs
# -----------------------------------------------------------------------------
# Output values for the Snowflake stage module.
# -----------------------------------------------------------------------------

output "stage_names" {
  description = "The names of the created stages."
  value = merge(
    { for k, v in snowflake_internal_stage.this : k => v.name },
    { for k, v in snowflake_external_stage_s3.this : k => v.name }
  )
}

output "stage_fully_qualified_names" {
  description = "The fully qualified names of the stages."
  value = merge(
    { for k, v in snowflake_internal_stage.this : k => v.fully_qualified_name },
    { for k, v in snowflake_external_stage_s3.this : k => v.fully_qualified_name }
  )
}

output "stage_databases" {
  description = "The databases containing the stages."
  value = merge(
    { for k, v in snowflake_internal_stage.this : k => v.database },
    { for k, v in snowflake_external_stage_s3.this : k => v.database }
  )
}

output "stage_schemas" {
  description = "The schemas containing the stages."
  value = merge(
    { for k, v in snowflake_internal_stage.this : k => v.schema },
    { for k, v in snowflake_external_stage_s3.this : k => v.schema }
  )
}

output "stage_urls" {
  description = "The URLs of external stages (null for internal stages)."
  value = merge(
    { for k, v in snowflake_internal_stage.this : k => null },
    { for k, v in snowflake_external_stage_s3.this : k => v.url }
  )
}

output "stage_types" {
  description = "The types of stages (INTERNAL or EXTERNAL)."
  value       = { for k, stage in var.stage_configs : k => stage.url != null ? "EXTERNAL" : "INTERNAL" }
}

output "internal_stages" {
  description = "All internal stage resources."
  value       = snowflake_internal_stage.this
}

output "external_stages" {
  description = "All external stage resources."
  value       = snowflake_external_stage_s3.this
}
