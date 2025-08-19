provider "snowflake" {}

provider "context" {
  properties = {
    "environment" = {}
    "name"        = {}
  }

  values = {
    environment = "DEV"
  }
}
