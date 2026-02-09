variable "stage_configs" {
  description = "Map of configuration objects for Snowflake stages"
  type = map(object({
    name                = string
    database            = string
    schema              = string
    url                 = optional(string, null)
    storage_integration = optional(string, null)
    credentials         = optional(string, null)
    encryption          = optional(string, null)
    file_format         = optional(string, null)
    copy_options        = optional(string, null)
    directory           = optional(string, null)
    comment             = optional(string, null)
  }))
  default = {}
}

# Snowflake authentication variables
variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
  default     = null
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
  default     = null
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
  default     = null
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = null
}

variable "snowflake_private_key" {
  description = "Snowflake private key for key-pair authentication"
  type        = string
  sensitive   = true
  default     = null
}
