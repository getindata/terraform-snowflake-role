module "snowflake_role" {
  source  = "../../"
  context = module.this.context

  name = "LOGS_DATABASE_READER"

  granted_to_users = ["JANE_SMITH", "JOHN_DOE"]

  database_grants = [
    {
      database_name = "LOGS_DB"
      privileges    = ["USAGE"]
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
}
