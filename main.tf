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

resource "snowflake_grant_ownership" "this" {
  count = module.this.enabled && var.role_ownership_grant != null ? 1 : 0

  account_role_name   = var.role_ownership_grant
  outbound_privileges = "REVOKE"
  on {
    object_type = "ROLE"
    object_name = one(snowflake_role.this[*].name)
  }
}

resource "snowflake_grant_account_role" "granted_roles" {
  for_each = toset(module.this.enabled ? var.granted_roles : [])

  parent_role_name = one(snowflake_role.this[*].name)
  role_name        = each.value
}

resource "snowflake_grant_account_role" "granted_to_roles" {
  for_each = toset(module.this.enabled ? var.granted_to_roles : [])

  role_name        = one(snowflake_role.this[*].name)
  parent_role_name = each.value
}

resource "snowflake_grant_account_role" "granted_to_users" {
  for_each = toset(module.this.enabled ? var.granted_to_users : [])

  role_name = one(snowflake_role.this[*].name)
  user_name = each.value
}

resource "snowflake_grant_database_role" "granted_db_roles" {
  for_each = toset(module.this.enabled ? var.granted_database_roles : [])

  database_role_name = each.value
  parent_role_name   = one(snowflake_role.this[*].name)
}


resource "snowflake_grant_privileges_to_account_role" "account_grants" {
  for_each = module.this.enabled ? local.account_grants : {}

  account_role_name = one(snowflake_role.this[*].name)
  on_account        = true

  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option
}

resource "snowflake_grant_privileges_to_account_role" "account_object_grants" {
  for_each = module.this.enabled ? local.account_objects_grants : {}

  account_role_name = one(snowflake_role.this[*].name)
  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option

  on_account_object {
    object_type = each.value.object_type
    object_name = each.value.object_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "schema_grants" {
  for_each = module.this.enabled ? local.schema_grants : {}

  account_role_name = one(snowflake_role.this[*].name)
  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option

  on_schema {
    all_schemas_in_database    = each.value.all_schemas_in_database == true ? each.value.database_name : null
    schema_name                = each.value.schema_name != null && !each.value.all_schemas_in_database && !each.value.future_schemas_in_database ? "\"${each.value.database_name}\".\"${each.value.schema_name}\"" : null
    future_schemas_in_database = each.value.future_schemas_in_database == true ? each.value.database_name : null
  }
}

resource "snowflake_grant_privileges_to_account_role" "schema_objects_grants" {
  for_each = module.this.enabled ? local.schema_objects_grants : {}

  account_role_name = one(snowflake_role.this[*].name)
  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option

  on_schema_object {
    object_type = each.value.object_type != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? each.value.object_type : null
    object_name = each.value.object_name != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? "\"${each.value.database_name}\".\"${each.value.schema_name}\".\"${each.value.object_name}\"" : null
    dynamic "all" {
      for_each = try(each.value.on_all, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? each.value.database_name : null
        in_schema          = each.value.schema_name != null ? "\"${each.value.database_name}\".\"${each.value.schema_name}\"" : null
      }
    }

    dynamic "future" {
      for_each = try(each.value.on_future, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? each.value.database_name : null
        in_schema          = each.value.schema_name != null ? "\"${each.value.database_name}\".\"${each.value.schema_name}\"" : null
      }
    }
  }
}
