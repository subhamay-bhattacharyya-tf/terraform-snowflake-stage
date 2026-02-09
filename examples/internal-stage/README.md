# Internal Stage Example

This example demonstrates how to create internal Snowflake stages using the `snowflake-stage` module.

## What is an Internal Stage?

Internal stages store data files internally within Snowflake. They are useful for:
- Temporary data storage during ETL processes
- Staging data before loading into tables
- Storing files that don't need external cloud storage

## Usage

```hcl
module "stage" {
  source = "../../modules/snowflake-stage"

  stage_configs = {
    "raw_stage" = {
      name     = "RAW_DATA_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal stage for raw data files"
    }
    "staging_stage" = {
      name        = "STAGING_AREA"
      database    = "MY_DATABASE"
      schema      = "STAGING"
      file_format = "TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1"
      comment     = "Internal stage with CSV format"
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| stage_configs | Map of stage configuration objects | `map(object)` | yes |
| snowflake_organization_name | Snowflake organization name | `string` | yes |
| snowflake_account_name | Snowflake account name | `string` | yes |
| snowflake_user | Snowflake username | `string` | yes |
| snowflake_role | Snowflake role | `string` | yes |
| snowflake_private_key | Snowflake private key (PEM format) | `string` | yes |

## Outputs

| Name | Description |
|------|-------------|
| stage_names | Map of created stage names |
| stage_fully_qualified_names | Map of fully qualified stage names |
| stage_databases | Map of databases containing the stages |
| stage_schemas | Map of schemas containing the stages |
| stage_types | Map of stage types (INTERNAL) |

## Running the Example

```bash
# Initialize Terraform
terraform init

# Set environment variables
export TF_VAR_snowflake_organization_name="your_org"
export TF_VAR_snowflake_account_name="your_account"
export TF_VAR_snowflake_user="your_user"
export TF_VAR_snowflake_role="SYSADMIN"
export TF_VAR_snowflake_private_key="$(cat ~/.snowflake/rsa_key.pem)"

# Plan and apply
terraform plan
terraform apply
```
