terraform {
  required_version = ">= 1.3.0"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = ">= 0.87.0"
    }
  }
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  role              = var.snowflake_role
  authenticator     = "JWT"
  private_key       = var.snowflake_private_key
}
