# External Stage Example

This example demonstrates how to create external Snowflake stages using the `snowflake-stage` module. External stages reference data files stored in cloud storage (S3, GCS, or Azure).

## What is an External Stage?

External stages point to data stored outside Snowflake in cloud storage services:
- **AWS S3** - `s3://bucket/path/`
- **Google Cloud Storage** - `gcs://bucket/path/`
- **Azure Blob Storage** - `azure://account.blob.core.windows.net/container/path/`

## Prerequisites

Before creating an external stage, you need:
1. A storage integration configured in Snowflake (recommended)
2. Or direct credentials (less secure)

## Usage

### With Storage Integration (Recommended)

```hcl
module "stage" {
  source = "../../modules/snowflake-stage"

  stage_configs = {
    "s3_stage" = {
      name                = "S3_DATA_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://my-data-bucket/ingest/"
      storage_integration = "MY_S3_INTEGRATION"
      file_format         = "TYPE = PARQUET"
      comment             = "External S3 stage for data ingestion"
    }
    "gcs_stage" = {
      name                = "GCS_ARCHIVE_STAGE"
      database            = "MY_DATABASE"
      schema              = "ARCHIVE"
      url                 = "gcs://my-archive-bucket/snowflake/"
      storage_integration = "MY_GCS_INTEGRATION"
      comment             = "External GCS stage for archived data"
    }
    "azure_stage" = {
      name                = "AZURE_LANDING_STAGE"
      database            = "MY_DATABASE"
      schema              = "LANDING"
      url                 = "azure://myaccount.blob.core.windows.net/landing/data/"
      storage_integration = "MY_AZURE_INTEGRATION"
      file_format         = "TYPE = JSON"
      comment             = "External Azure stage for landing zone"
    }
  }
}
```

### Mixed Internal and External Stages

```hcl
module "stage" {
  source = "../../modules/snowflake-stage"

  stage_configs = {
    "internal_temp" = {
      name     = "TEMP_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal temporary stage"
    }
    "external_s3" = {
      name                = "S3_INGEST"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://data-lake/ingest/"
      storage_integration = "S3_INTEGRATION"
      comment             = "External S3 stage"
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
| stage_urls | Map of external stage URLs |
| stage_types | Map of stage types (INTERNAL or EXTERNAL) |

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

## Creating a Storage Integration

Before using external stages with storage integration, create the integration:

```sql
-- Example for S3
CREATE STORAGE INTEGRATION my_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://my-bucket/');
```
