# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Variables
# -----------------------------------------------------------------------------
# Input variables for the Snowflake stage module.
# -----------------------------------------------------------------------------

variable "stage_configs" {
  description = "Map of configuration objects for Snowflake stages (internal and external)"
  type = map(object({
    name                = string
    database            = string
    schema              = string
    url                 = optional(string, null)
    storage_integration = optional(string, null)
    comment             = optional(string, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, stage in var.stage_configs : length(stage.name) > 0])
    error_message = "Stage name must not be empty."
  }

  validation {
    condition     = alltrue([for k, stage in var.stage_configs : length(stage.database) > 0])
    error_message = "Database name must not be empty."
  }

  validation {
    condition     = alltrue([for k, stage in var.stage_configs : length(stage.schema) > 0])
    error_message = "Schema name must not be empty."
  }

  validation {
    condition = alltrue([
      for k, stage in var.stage_configs :
      stage.url == null || can(regex("^s3://", stage.url))
    ])
    error_message = "External stage URL must start with s3://."
  }
}
