provider "snowflake" {}

provider "context" {
  properties = {
    "environment" = {}
    "name"        = { required = true }
    "project"     = {}
  }

  delimiter = "_"

  values = {
    environment = "DEV"
    project     = "PROJECT"
  }
}
