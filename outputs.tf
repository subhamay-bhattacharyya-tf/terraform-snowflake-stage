output "stage_names" {
  description = "The names of the created stages."
  value       = { for k, v in snowflake_stage.this : k => v.name }
}

output "stage_fully_qualified_names" {
  description = "The fully qualified names of the stages."
  value       = { for k, v in snowflake_stage.this : k => v.fully_qualified_name }
}

output "stage_databases" {
  description = "The databases containing the stages."
  value       = { for k, v in snowflake_stage.this : k => v.database }
}

output "stage_schemas" {
  description = "The schemas containing the stages."
  value       = { for k, v in snowflake_stage.this : k => v.schema }
}

output "stage_urls" {
  description = "The URLs of external stages (null for internal stages)."
  value       = { for k, v in snowflake_stage.this : k => v.url }
}

output "stage_types" {
  description = "The types of stages (INTERNAL or EXTERNAL)."
  value       = { for k, stage in var.stage_configs : k => stage.url != null ? "EXTERNAL" : "INTERNAL" }
}

output "stages" {
  description = "All stage resources."
  value       = snowflake_stage.this
}
