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

output "stage_types" {
  description = "The types of stages (INTERNAL or EXTERNAL)"
  value       = module.stage.stage_types
}
