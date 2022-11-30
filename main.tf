module "role_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = "_"
  regex_replace_chars = "/[^_a-zA-Z0-9]/"
}

resource "snowflake_role" "this" {
  count = module.this.enabled ? 1 : 0

  name    = upper(local.name_from_descriptor)
  comment = var.comment
}

resource "snowflake_role_ownership_grant" "this" {
  count = module.this.enabled && var.role_ownership_grant != null ? 1 : 0

  on_role_name = one(snowflake_role.this[*].name)
  to_role_name = var.role_ownership_grant
}

resource "snowflake_role_grants" "granted_roles" {
  for_each = toset(module.this.enabled ? local.granted_roles : [])

  role_name = each.value
  roles     = [one(snowflake_role.this[*].name)]
}

resource "snowflake_role_grants" "granted_to" {
  count = module.this.enabled && (length(local.granted_to_roles) > 0 || length(local.granted_to_users) > 0) ? 1 : 0

  role_name = one(snowflake_role.this[*].name)
  roles     = local.granted_to_roles
  users     = local.granted_to_users
}

resource "snowflake_database_grant" "this" {
  for_each = module.this.enabled ? local.database_grants : {}

  database_name = each.value.database_name
  privilege     = each.value.privilege
  roles         = [one(snowflake_role.this[*].name)]
}

resource "snowflake_schema_grant" "this" {
  for_each = module.this.enabled ? local.schema_grants : {}

  database_name = each.value.database_name
  schema_name   = each.value.schema_name
  privilege     = each.value.privilege
  roles         = [one(snowflake_role.this[*].name)]
}

resource "snowflake_table_grant" "this" {
  for_each = module.this.enabled ? local.table_grants : {}

  database_name = each.value.database_name
  schema_name   = each.value.schema_name
  table_name    = each.value.table_name
  privilege     = each.value.privilege
  on_future     = each.value.on_future
  roles         = [one(snowflake_role.this[*].name)]
}

resource "snowflake_external_table_grant" "this" {
  for_each = module.this.enabled ? local.external_table_grants : {}

  database_name       = each.value.database_name
  schema_name         = each.value.schema_name
  external_table_name = each.value.external_table_name
  privilege           = each.value.privilege
  on_future           = each.value.on_future
  roles               = [one(snowflake_role.this[*].name)]
}

resource "snowflake_account_grant" "this" {
  for_each = toset(module.this.enabled ? var.account_grants : [])

  privilege = each.value
  roles     = [one(snowflake_role.this[*].name)]

  with_grant_option = false
}
