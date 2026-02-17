# External Stage Example

This example demonstrates how to create external Snowflake stages using the snowflake-stage module.

## Overview

External stages reference data files stored in external cloud storage locations:
- AWS S3 (`s3://`)
- Google Cloud Storage (`gcs://`)
- Azure Blob Storage (`azure://`)

External stages require either a storage integration or credentials for authentication.

## Usage

### S3 External Stage with Storage Integration

```hcl
module "stage" {
  source = "../../"

  stage_configs = {
    "s3_stage" = {
      name                = "MY_S3_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://my-bucket/data/"
      storage_integration = "MY_S3_INTEGRATION"
      comment             = "External S3 stage"
    }
  }
}
```

### GCS External Stage

```hcl
module "stage" {
  source = "../../"

  stage_configs = {
    "gcs_stage" = {
      name                = "MY_GCS_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "gcs://my-bucket/data/"
      storage_integration = "MY_GCS_INTEGRATION"
      comment             = "External GCS stage"
    }
  }
}
```

### Azure External Stage

```hcl
module "stage" {
  source = "../../"

  stage_configs = {
    "azure_stage" = {
      name                = "MY_AZURE_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "azure://myaccount.blob.core.windows.net/container/path/"
      storage_integration = "MY_AZURE_INTEGRATION"
      comment             = "External Azure stage"
    }
  }
}
```

## Prerequisites

Before creating external stages, you need:
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
| stage_names | The names of the created stages |
| stage_fully_qualified_names | The fully qualified names of the stages |
| stage_databases | The databases containing the stages |
| stage_schemas | The schemas containing the stages |
| stage_urls | The URLs of external stages |
| stage_types | The types of stages (EXTERNAL) |
