# Terraform Snowflake Module - Stage

![Release](https://github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage/actions/workflows/ci.yaml/badge.svg)&nbsp;![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?logo=snowflake&logoColor=white)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-tf/terraform-snowflake-stage)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/89743ade0aca656d28e717c9eb799f6c/raw/terraform-snowflake-stage.json?)

A Terraform module for creating and managing Snowflake stages using a map of configuration objects. Supports both internal and external stages (S3) with a single module call.

## Features

- Map-based configuration for creating single or multiple stages
- Support for internal stages (Snowflake-managed storage)
- Support for external stages (S3)
- Storage integration support for secure cloud access
- Built-in input validation with descriptive error messages
- Sensible defaults for optional properties
- Outputs keyed by stage identifier for easy reference
- File format and copy options configuration

## Usage

### Internal Stage

```hcl
module "stage" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage"

  stage_configs = {
    "my_internal_stage" = {
      name     = "MY_INTERNAL_STAGE"
      database = "MY_DATABASE"
      schema   = "PUBLIC"
      comment  = "Internal stage for data loading"
    }
  }
}
```

### External Stage (S3)

```hcl
module "stage" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage"

  stage_configs = {
    "my_s3_stage" = {
      name                = "MY_S3_STAGE"
      database            = "MY_DATABASE"
      schema              = "PUBLIC"
      url                 = "s3://my-bucket/path/"
      storage_integration = "MY_S3_INTEGRATION"
      comment             = "External S3 stage for data ingestion"
    }
  }
}
```

### Multiple Stages

```hcl
locals {
  stages = {
    "raw_stage" = {
      name     = "RAW_DATA_STAGE"
      database = "MY_DATABASE"
      schema   = "RAW"
      comment  = "Internal stage for raw data files"
    }
    "s3_ingest" = {
      name                = "S3_INGEST_STAGE"
      database            = "MY_DATABASE"
      schema              = "STAGING"
      url                 = "s3://data-lake/ingest/"
      storage_integration = "S3_INTEGRATION"
      comment             = "External stage for S3 data ingestion"
    }
    "archive_stage" = {
      name                = "ARCHIVE_STAGE"
      database            = "MY_DATABASE"
      schema              = "ARCHIVE"
      url                 = "s3://data-archive/snowflake/"
      storage_integration = "S3_INTEGRATION"
      comment             = "External stage for archived data"
    }
  }
}

module "stages" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage"

  stage_configs = local.stages
}
```

## Examples

- [Internal Stage](examples/internal-stage) - Create internal Snowflake stages
- [External Stage](examples/external-stage) - Create external stages (S3)
- [Multiple Stages](examples/multiple-stages) - Create multiple stages (internal and external) in a single call

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| snowflake | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| snowflake | >= 1.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| stage_configs | Map of configuration objects for Snowflake stages | `map(object)` | `{}` | no |

### stage_configs Object Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| name | string | - | Stage identifier (required) |
| database | string | - | Database name (required) |
| schema | string | - | Schema name (required) |
| url | string | null | External stage URL (s3://) |
| storage_integration | string | null | Storage integration name for external stages |
| credentials | string | null | Credentials for external stages (alternative to storage_integration) |
| encryption | string | null | Encryption settings |
| comment | string | null | Description of the stage |

### Stage Types

- **Internal Stage**: No URL specified - Snowflake manages the storage (uses `snowflake_stage_internal`)
- **External Stage**: URL specified pointing to S3 cloud storage (uses `snowflake_stage_external_s3`)

### Supported External Stage URLs

| Cloud Provider | URL Format |
|----------------|------------|
| AWS S3 | `s3://bucket-name/path/` |

## Outputs

| Name | Description |
|------|-------------|
| stage_names | Map of stage names keyed by identifier |
| stage_fully_qualified_names | Map of fully qualified stage names |
| stage_databases | Map of databases containing the stages |
| stage_schemas | Map of schemas containing the stages |
| stage_urls | Map of external stage URLs (null for internal) |
| stage_types | Map of stage types (INTERNAL or EXTERNAL) |
| internal_stages | All internal stage resources |
| external_stages | All external stage resources |

## Validation

The module validates inputs and provides descriptive error messages for:

- Empty stage name
- Empty database name
- Empty schema name
- Invalid external stage URL format
- Conflicting storage_integration and credentials

## Testing

The module includes Terratest-based integration tests:

```bash
cd test
go mod tidy
go test -v -timeout 30m
```

Required environment variables for testing:
- `SNOWFLAKE_ORGANIZATION_NAME` - Snowflake organization name
- `SNOWFLAKE_ACCOUNT_NAME` - Snowflake account name
- `SNOWFLAKE_USER` - Snowflake username
- `SNOWFLAKE_ROLE` - Snowflake role (e.g., "SYSADMIN")
- `SNOWFLAKE_PRIVATE_KEY` - Snowflake private key for key-pair authentication

For external stage tests:
- `SNOWFLAKE_STORAGE_INTEGRATION` - Storage integration name
- `SNOWFLAKE_TEST_S3_BUCKET` - S3 bucket for testing

## CI/CD Configuration

The CI workflow runs on:
- Push to `main`, `feature/**`, and `bug/**` branches (when `*.tf`, `examples/**`, or `test/**` changes)
- Pull requests to `main` (when `*.tf`, `examples/**`, or `test/**` changes)
- Manual workflow dispatch

The workflow includes:
- Terraform validation and format checking
- Examples validation
- Terratest integration tests (output displayed in GitHub Step Summary)
- Changelog generation (non-main branches)
- Semantic release (main branch only)

The CI workflow uses the following GitHub organization variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `TERRAFORM_VERSION` | Terraform version for CI jobs | `1.3.0` |
| `GO_VERSION` | Go version for Terratest | `1.21` |
| `SNOWFLAKE_ORGANIZATION_NAME` | Snowflake organization name | - |
| `SNOWFLAKE_ACCOUNT_NAME` | Snowflake account name | - |
| `SNOWFLAKE_USER` | Snowflake username | - |
| `SNOWFLAKE_ROLE` | Snowflake role (e.g., SYSADMIN) | - |
| `SNOWFLAKE_STORAGE_INTEGRATION` | Storage integration for external stage tests | - |
| `SNOWFLAKE_TEST_S3_BUCKET` | S3 bucket for external stage tests | - |

The following GitHub secrets are required for Terratest integration tests:

| Secret | Description | Required |
|--------|-------------|----------|
| `SNOWFLAKE_PRIVATE_KEY` | Snowflake private key for key-pair authentication | Yes |

## License

MIT License - See [LICENSE](LICENSE) for details.
