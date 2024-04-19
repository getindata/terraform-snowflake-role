module "role_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = coalesce(module.this.context.delimiter, "_")
  regex_replace_chars = coalesce(module.this.context.regex_replace_chars, "/[^_a-zA-Z0-9]/")
  label_value_case    = coalesce(module.this.context.label_value_case, "upper")
}

resource "snowflake_role" "this" {
  count = module.this.enabled ? 1 : 0

  name    = local.name_from_descriptor
  comment = var.comment
}

resource "snowflake_grant_account_role" "granted_to_users" {
  for_each  = toset(module.this.enabled ? var.granted_to_users : [])
  role_name = snowflake_role.this[*].name
  user_name = each.value
}

resource "snowflake_grant_database_role" "this" {
  count = module.this.enabled ? 1 : 0

  database_role_name = "${module.snowflake_database_role.database}.${module.snowflake_database_role.name}}"
  parent_role_name   = snowflake_role.this[*].name
}

module "snowflake_database_role" {
  source                = "git@github.com:getindata/terraform-snowflake-database-role.git?ref=feat/snowflake-db-role-ps"
  context               = module.this.context
  database_name         = var.database_name
  name                  = var.database_role_name
  database_grants       = var.database_grants
  schema_grants         = var.schema_grants
  schema_objects_grants = var.schema_objects_grants

}

resource "snowflake_grant_ownership" "this" {
  count = module.this.enabled && var.role_ownership_grant != null ? 1 : 0

  account_role_name = var.role_ownership_grant
  on {
    object_type = "ROLE"
    object_name = snowflake_role.this[*].name
  }
}

resource "snowflake_grant_account_role" "granted_roles" {
  for_each         = toset(module.this.enabled ? var.granted_roles : [])
  role_name        = each.value
  parent_role_name = snowflake_role.this[*].name
}

resource "snowflake_grant_account_role" "granted_to" {
  for_each         = toset(module.this.enabled ? var.granted_to_roles : [])
  role_name        = snowflake_role.role.name
  parent_role_name = each.value
}
