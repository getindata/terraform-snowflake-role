locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

  granted_roles    = compact(var.granted_roles)
  granted_to_roles = compact(var.granted_to_roles)
  granted_to_users = compact(var.granted_to_users)

  database_grants = merge([for database_grant in var.database_grants : {
    for privilege in database_grant.privileges : "${database_grant.database_name}/${privilege}" => {
      database_name = database_grant.database_name
      privilege     = privilege
    }
  }]...)

  schema_grants = merge([for schema_grant in var.schema_grants : {
    for privilege in schema_grant.privileges : "${schema_grant.database_name}/${schema_grant.schema_name}/${privilege}" => {
      database_name = schema_grant.database_name
      schema_name   = schema_grant.schema_name
      privilege     = privilege
    }
  }]...)

  table_grants = merge([for table_grant in var.table_grants : {
    for privilege in table_grant.privileges : "${table_grant.database_name}/${table_grant.schema_name}/${coalesce(table_grant.table_name, "on_future")}/${privilege}" => {
      database_name = table_grant.database_name
      schema_name   = table_grant.schema_name
      table_name    = table_grant.table_name
      on_future     = table_grant.on_future
      privilege     = privilege
    }
  }]...)

  external_table_grants = merge([for table_grant in var.external_table_grants : {
    for privilege in table_grant.privileges : "${table_grant.database_name}/${table_grant.schema_name}/${coalesce(table_grant.external_table_name, "on_future")}/${privilege}" => {
      database_name       = table_grant.database_name
      schema_name         = table_grant.schema_name
      external_table_name = table_grant.external_table_name
      on_future           = table_grant.on_future
      privilege           = privilege
    }
  }]...)
}
