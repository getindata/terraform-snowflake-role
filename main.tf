data "context_label" "this" {
  delimiter  = local.context_template == null ? var.naming_scheme.delimiter : null
  properties = local.context_template == null ? var.naming_scheme.properties : null
  template   = local.context_template

  replace_chars_regex = var.naming_scheme.replace_chars_regex

  values = merge(
    var.naming_scheme.extra_labels,
    { name = var.name }
  )
}

resource "snowflake_account_role" "this" {
  name    = data.context_label.this.rendered
  comment = var.comment
}
moved {
  from = snowflake_account_role.this[0]
  to   = snowflake_account_role.this
}

resource "snowflake_grant_ownership" "this" {
  count = var.role_ownership_grant != null ? 1 : 0

  account_role_name   = var.role_ownership_grant
  outbound_privileges = "REVOKE"
  on {
    object_type = "ROLE"
    object_name = snowflake_account_role.this.name
  }
}

resource "snowflake_grant_account_role" "granted_roles" {
  for_each = toset(var.granted_roles)

  parent_role_name = snowflake_account_role.this.name
  role_name        = each.value
}

resource "snowflake_grant_account_role" "granted_to_roles" {
  for_each = toset(var.granted_to_roles)

  role_name        = snowflake_account_role.this.name
  parent_role_name = each.value
}

resource "snowflake_grant_account_role" "granted_to_users" {
  for_each = toset(var.granted_to_users)

  role_name = snowflake_account_role.this.name
  user_name = each.value
}

resource "snowflake_grant_database_role" "granted_db_roles" {
  for_each = toset(var.granted_database_roles)

  database_role_name = each.value
  parent_role_name   = snowflake_account_role.this.name
}


resource "snowflake_grant_privileges_to_account_role" "account_grants" {
  for_each = local.account_grants

  account_role_name = snowflake_account_role.this.name
  on_account        = true

  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option
}

resource "snowflake_grant_privileges_to_account_role" "account_object_grants" {
  for_each = local.account_objects_grants

  account_role_name = snowflake_account_role.this.name
  all_privileges    = each.value.all_privileges
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option

  on_account_object {
    object_type = each.value.object_type
    object_name = each.value.object_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "schema_grants" {
  for_each = local.schema_grants

  account_role_name = snowflake_account_role.this.name
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
  for_each = local.schema_objects_grants

  account_role_name = snowflake_account_role.this.name
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
