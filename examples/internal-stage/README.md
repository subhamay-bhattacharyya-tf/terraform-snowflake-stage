# Internal Stage Example

This example demonstrates how to create internal Snowflake stages using the snowflake-stage module.

## Overview

Internal stages store data files in Snowflake-managed cloud storage. They are useful for:
- Temporary data staging during ETL processes
- Storing files that will be loaded into Snowflake tables
- Sharing data between Snowflake users within the same account

## Usage

```hcl
module "stage" {
  source = "../../"

  stage_configs = {
    "raw_data_stage" = {
      name     = "RAW_DATA_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal stage for raw data files"
    }
  }
}
```

## Running the Example

1. Set the required environment variables:

```bash
export TF_VAR_snowflake_organization_name="your_org"
export TF_VAR_snowflake_account_name="your_account"
export TF_VAR_snowflake_user="your_user"
export TF_VAR_snowflake_role="SYSADMIN"
export TF_VAR_snowflake_private_key="$(cat ~/.snowflake/rsa_key.p8)"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| stage_configs | Map of stage configuration objects | map(object) | yes |
| snowflake_organization_name | Snowflake organization name | string | yes |
| snowflake_account_name | Snowflake account name | string | yes |
| snowflake_user | Snowflake username | string | yes |
| snowflake_role | Snowflake role | string | no |
| snowflake_private_key | Snowflake private key | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| stage_names | The names of the created stages |
| stage_fully_qualified_names | The fully qualified names of the stages |
| stage_databases | The databases containing the stages |
| stage_schemas | The schemas containing the stages |
| stage_types | The types of stages (INTERNAL) |
