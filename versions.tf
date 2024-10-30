terraform {
  required_version = ">= 1.3"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.94"
    }
    context = {
      source  = "cloudposse/context"
      version = ">=0.4.0"
    }
  }
}
