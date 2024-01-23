module "snowflake_role" {
  source  = "../../"
  context = module.this.context

  name = "LOGS_DATABASE_READER"

  granted_to_users = ["JANE_SMITH", "JOHN_DOE"]

  database_grants = [
    {
      database_name          = "LOGS_DB"
      privileges             = ["USAGE"]
      enable_multiple_grants = true
    }
  ]

  schema_grants = [
    {
      database_name = "LOGS_DB"
      schema_name   = "BRONZE"
      privileges    = ["USAGE"]
    }
  ]

  table_grants = [
    {
      database_name = "LOGS_DB"
      schema_name   = "BRONZE"
      on_future     = true
      privileges    = ["SELECT"]
    }
  ]

  view_grants = [
    {
      database_name = "LOGS_DB"
      schema_name   = "BRONZE"
      on_all        = true
      privileges    = ["SELECT"]
    }
  ]

  dynamic_table_grants = [
    {
      database_name  = "LOGS_DB"
      on_all         = true
      on_future      = true
      all_privileges = true
    },
    {
      database_name  = "TEST_DB"
      schema_name    = "BRONZE"
      on_all         = true
      all_privileges = true
    },
    {
      database_name      = "TEST_DB"
      schema_name        = "SILVER"
      dynamic_table_name = "EXAMPLE"
      privileges         = ["SELECT"]
    },
  ]
}
