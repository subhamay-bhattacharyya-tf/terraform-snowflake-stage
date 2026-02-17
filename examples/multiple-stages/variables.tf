# -----------------------------------------------------------------------------
# Terraform Snowflake Stage Module - Multiple Stages Example - Variables
# -----------------------------------------------------------------------------
# Input variables for the multiple stages example.
# -----------------------------------------------------------------------------

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
    comment             = optional(string, null)
  }))
  default = {
    "internal_stage" = {
      name     = "MY_INTERNAL_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal stage for data loading"
    }
    "external_stage" = {
      name                = "MY_S3_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://my-bucket/data/"
      storage_integration = "MY_S3_INTEGRATION"
      comment             = "External S3 stage for data ingestion"
    }
  }
}

# Snowflake Provider Configuration Variables
variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = "SYSADMIN"
}

variable "snowflake_private_key" {
  description = "Snowflake private key for key-pair authentication"
  type        = string
  sensitive   = true
}
