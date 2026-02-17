# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - External Stage Example - Outputs
# -----------------------------------------------------------------------------
# Output values for the external stage example.
# -----------------------------------------------------------------------------

output "stage_names" {
  description = "The names of the created stages"
  value       = module.stage.stage_names
}

output "stage_fully_qualified_names" {
  description = "The fully qualified names of the stages"
  value       = module.stage.stage_fully_qualified_names
}

output "stage_databases" {
  description = "The databases containing the stages"
  value       = module.stage.stage_databases
}

output "stage_schemas" {
  description = "The schemas containing the stages"
  value       = module.stage.stage_schemas
}

output "stage_urls" {
  description = "The URLs of external stages"
  value       = module.stage.stage_urls
}

output "stage_types" {
  description = "The types of stages (EXTERNAL)"
  value       = module.stage.stage_types
}

output "external_stages" {
  description = "All external stage resources"
  value       = module.stage.external_stages
}
