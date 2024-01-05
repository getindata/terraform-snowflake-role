locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

  granted_roles    = var.granted_roles
  granted_to_roles = var.granted_to_roles
  granted_to_users = var.granted_to_users

  database_grants = merge([for database_grant in var.database_grants : {
    for privilege in database_grant.privileges : "${database_grant.database_name}/${privilege}" => {
      database_name = database_grant.database_name
      privilege     = privilege
    }
  }]...)

  schema_grants = merge([for schema_grant in var.schema_grants : {
    for privilege in schema_grant.privileges : "${schema_grant.database_name}/${coalesce(schema_grant.schema_name, schema_grant.on_future != null ? "on_future" : "on_all")}/${privilege}" => {
      database_name = schema_grant.database_name
      schema_name   = schema_grant.schema_name
      on_future     = schema_grant.on_future
      on_all        = schema_grant.on_all
      privilege     = privilege
    }
  }]...)

  table_grants = merge([for table_grant in var.table_grants : {
    for privilege in table_grant.privileges : "${table_grant.database_name}/${table_grant.schema_name}/${coalesce(table_grant.table_name, table_grant.on_future != null ? "on_future" : "on_all")}/${privilege}" => {
      database_name = table_grant.database_name
      schema_name   = table_grant.schema_name
      table_name    = table_grant.table_name
      on_future     = table_grant.on_future
      on_all        = table_grant.on_all
      privilege     = privilege
    }
  }]...)

  external_table_grants = merge([for table_grant in var.external_table_grants : {
    for privilege in table_grant.privileges : "${table_grant.database_name}/${table_grant.schema_name}/${coalesce(table_grant.external_table_name, table_grant.on_future != null ? "on_future" : "on_all")}/${privilege}" => {
      database_name       = table_grant.database_name
      schema_name         = table_grant.schema_name
      external_table_name = table_grant.external_table_name
      on_future           = table_grant.on_future
      on_all              = table_grant.on_all
      privilege           = privilege
    }
  }]...)

  view_grants = merge([for view_grant in var.view_grants : {
    for privilege in view_grant.privileges : "${view_grant.database_name}/${view_grant.schema_name}/${coalesce(view_grant.view_name, view_grant.on_future != null ? "on_future" : "on_all")}/${privilege}" => {
      database_name = view_grant.database_name
      schema_name   = view_grant.schema_name
      view_name     = view_grant.view_name
      on_future     = view_grant.on_future
      on_all        = view_grant.on_all
      privilege     = privilege
    }
  }]...)

  dynamic_table_grants = merge([for grant in var.dynamic_table_grants : {
    for key, value in { "dynamic_table_name" = grant.dynamic_table_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${grant.database_name}/${coalesce(grant.schema_name, "all")}/${key == "dynamic_table_name" ? value : key}" => {
      database_name      = grant.database_name
      schema_name        = grant.schema_name
      dynamic_table_name = key == "dynamic_table_name" ? value : null
      on_future          = key == "on_future" ? value : false
      on_all             = key == "on_all" ? value : false
      privileges         = grant.privileges
      all_privileges     = grant.all_privileges
    } if(key == "dynamic_table_name" && value != null) || value == true
  }]...)
}
