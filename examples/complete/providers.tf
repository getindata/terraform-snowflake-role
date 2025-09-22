provider "snowflake" {
  preview_features_enabled = [
    "snowflake_table_resource",
    "snowflake_dynamic_table_resource"
  ]
}

provider "context" {
  properties = {
    "environment" = {}
    "name"        = {}
  }

  values = {
    environment = "DEV"
  }
}
