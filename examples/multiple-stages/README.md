# Multiple Stages Example

This example demonstrates how to create both internal and external Snowflake stages using a single module call.

## Overview

This example creates:
- 1 internal stage (Snowflake-managed storage)
- 1 external stage (S3 storage)

This pattern is useful for:
- Setting up a data pipeline with both internal and external staging areas
- Managing different stage types in a single configuration

## Usage

```hcl
module "stages" {
  source = "../../"

  stage_configs = {
    # Internal stage
    "internal_stage" = {
      name     = "MY_INTERNAL_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal stage for data loading"
      grants = [
        {
          role_name  = "DATA_ENGINEER"
          privileges = ["READ", "WRITE"]
        }
      ]
    }
    
    # External stage
    "external_stage" = {
      name                = "MY_S3_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://my-bucket/data/"
      storage_integration = "MY_S3_INTEGRATION"
      comment             = "External S3 stage for data ingestion"
      grants = [
        {
          role_name  = "DATA_ENGINEER"
          privileges = ["READ"]
        },
        {
          role_name  = "DATA_ANALYST"
          privileges = ["READ"]
        }
      ]
    }
  }
}
```

## Prerequisites

For external stages, you need:
1. A storage integration configured in Snowflake
2. Appropriate IAM roles/permissions on the cloud storage

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
| stage_names | The names of all created stages |
| stage_fully_qualified_names | The fully qualified names of the stages |
| stage_databases | The databases containing the stages |
| stage_schemas | The schemas containing the stages |
| stage_urls | The URLs of external stages (null for internal) |
| stage_types | The types of stages (INTERNAL or EXTERNAL) |
| internal_stages | List of internal stage names |
| external_stages | List of external stage names |
