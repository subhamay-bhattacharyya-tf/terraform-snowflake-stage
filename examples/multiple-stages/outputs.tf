# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Multiple Stages Example - Outputs
# -----------------------------------------------------------------------------
# Output values for the multiple stages example.
# -----------------------------------------------------------------------------

output "stage_names" {
  description = "The names of the created stages"
  value       = module.stages.stage_names
}

output "stage_fully_qualified_names" {
  description = "The fully qualified names of the stages"
  value       = module.stages.stage_fully_qualified_names
}

output "stage_databases" {
  description = "The databases containing the stages"
  value       = module.stages.stage_databases
}

output "stage_schemas" {
  description = "The schemas containing the stages"
  value       = module.stages.stage_schemas
}

output "stage_urls" {
  description = "The URLs of external stages (null for internal)"
  value       = module.stages.stage_urls
}

output "stage_types" {
  description = "The types of stages (INTERNAL or EXTERNAL)"
  value       = module.stages.stage_types
}

output "internal_stages" {
  description = "All internal stage resources"
  value       = module.stages.internal_stages
}

output "external_stages" {
  description = "All external S3 stage resources"
  value       = module.stages.external_stages
}
