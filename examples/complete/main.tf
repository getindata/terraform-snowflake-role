resource "snowflake_database" "this" {
  name = "SAMPLE_DB"
}

resource "snowflake_warehouse" "this" {
  name = "SAMPLE_WAREHOUSE"
}

resource "snowflake_schema" "schema_1" {
  name     = "BRONZE"
  database = snowflake_database.this.name
}

resource "snowflake_schema" "schema_2" {
  name     = "SILVER"
  database = snowflake_database.this.name
}

resource "snowflake_account_role" "role_1" {
  name = "SAMPLE_ROLE_1"
}

resource "snowflake_account_role" "role_2" {
  name = "SAMPLE_ROLE_2"
}

resource "snowflake_database_role" "this" {
  name     = "SAMPLE_DB_ROLE"
  database = snowflake_database.this.name
}

resource "snowflake_user" "this" {
  name = "SAMPLE_USER"
}

resource "snowflake_table" "this" {
  name     = "EXAMPLE"
  schema   = snowflake_schema.schema_1.name
  database = snowflake_database.this.name

  column {
    name = "ID"
    type = "NUMBER"
  }
}

resource "snowflake_dynamic_table" "this" {
  name = "EXAMPLE"

  database  = snowflake_database.this.name
  warehouse = snowflake_warehouse.this.name
  schema    = snowflake_schema.schema_2.name
  query     = "SELECT * from ${snowflake_table.this.database}.${snowflake_table.this.schema}.${snowflake_table.this.name}"
  target_lag {
    maximum_duration = 3600
  }
}

module "snowflake_role_1" {
  source = "../../"

  name              = "SAMPLE_TEST_1"
  context_templates = var.context_templates

  role_ownership_grant = "SYSADMIN"

  granted_to_users = ["SAMPLE_USER"]
  granted_to_roles = [snowflake_account_role.role_1.name]

  granted_roles          = [snowflake_account_role.role_2.name]
  granted_database_roles = ["${snowflake_database.this.name}.${snowflake_database_role.this.name}"]

  account_grants = [{
    privileges = ["CREATE DATABASE"]
  }]

  account_objects_grants = {
    DATABASE = [
      {
        privileges  = ["USAGE"]
        object_name = snowflake_database.this.name
      },
    ]
    WAREHOUSE = [
      {
        all_privileges    = true
        with_grant_option = true
        object_name       = snowflake_warehouse.this.name
      }
    ]
  }

  schema_grants = [
    {
      database_name = snowflake_database.this.name
      schema_name   = snowflake_schema.schema_1.name
      privileges    = ["USAGE"]
    },
    {
      database_name              = snowflake_database.this.name
      schema_name                = snowflake_schema.schema_2.name
      all_privileges             = true
      future_schemas_in_database = true
      with_grant_option          = true
    },
  ]

  schema_objects_grants = {
    TABLE = [
      {
        database_name     = snowflake_database.this.name
        schema_name       = snowflake_schema.schema_1.name
        on_all            = true
        on_future         = true
        all_privileges    = true
        with_grant_option = true
      }
    ]

    VIEW = [
      {
        database_name = snowflake_database.this.name
        on_future     = true
        privileges    = ["SELECT"]
      }
    ]

    "DYNAMIC TABLE" = [
      {
        database_name  = snowflake_database.this.name
        schema_name    = snowflake_schema.schema_1.name
        on_all         = true
        all_privileges = true
      },
      {
        database_name = snowflake_database.this.name
        schema_name   = snowflake_schema.schema_2.name
        object_name   = "EXAMPLE"
        privileges    = ["SELECT"]
      },
    ]
  }

  # depends_on = [
  #   snowflake_database.this,
  #   snowflake_warehouse.this,
  #   snowflake_schema.schema_1,
  #   snowflake_schema.schema_2,
  #   snowflake_account_role.role_1,
  #   snowflake_account_role.role_2,
  #   snowflake_database_role.this,
  #   snowflake_user.this,
  #   snowflake_table.this,
  #   snowflake_dynamic_table.this,
  # ]
}

module "snowflake_role_2" {
  source = "../../"

  name              = "SAMPLE_TEST_2"
  context_templates = var.context_templates
  naming_scheme = {
    context_template_name = "snowflake-project-role"
    extra_labels = {
      project = "PROJECT"
    }
  }

  account_grants = [
    {
      privileges = ["CREATE DATABASE"]
    }
  ]

  account_objects_grants = {
    "DATABASE" = [
      {
        all_privileges = true
        object_name    = snowflake_database.this.name
      }
    ]
  }
}

module "snowflake_role_3" {
  source = "../../"

  name = "SAMPLE-TEST-3"
  naming_scheme = {
    properties          = ["name", "schema", "environment"]
    delimiter           = "_"
    replace_chars_regex = "-"
    extra_labels        = { schema = "SCHEMA" }
  }
}
