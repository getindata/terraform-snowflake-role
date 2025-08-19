terraform {
  required_version = ">= 1.3.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 0.94"
    }
    context = {
      source  = "cloudposse/context"
      version = ">=0.4.0"
    }
  }
}
