locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

  account_grants = {
    for index, grant in var.account_grants : grant.all_privileges == true ? "ALL" : "CUSTOM_${index}" => grant
  }

  account_objects_grants = {
    for index, grant in flatten([
      for object_type, grants in var.account_objects_grants : [
        for grant in grants :
        merge(
          grant,
          {
            object_type = object_type
          }
        )
      ]
    ]) : grant.all_privileges == true ? "${grant.object_type}_${grant.object_name}_ALL" : "${grant.object_type}_${grant.object_name}_CUSTOM_${index}" => grant
  }

  schema_grants = {
    for index, schema_grant in flatten([
      for grant in var.schema_grants : grant.future_schemas_in_database && grant.all_schemas_in_database ? [
        merge(
          grant,
          {
            future_schemas_in_database = true,
            all_schemas_in_database    = false
          }
        ),
        merge(
          grant,
          {
            future_schemas_in_database = false,
            all_schemas_in_database    = true
          }
        )
      ] : [grant]
    ]) :
    "${schema_grant.schema_name != null ? "${schema_grant.database_name}_${schema_grant.schema_name}" :
      schema_grant.all_schemas_in_database != false ? "${schema_grant.database_name}_ALL_SCHEMAS" :
      schema_grant.future_schemas_in_database != false ? "${schema_grant.database_name}_FUTURE_SCHEMAS" : ""
    }_${schema_grant.all_privileges == true ? "ALL" : "CUSTOM_${index}"}" => schema_grant
  }

  schema_objects_grants = {
    for index, grant in flatten([
      for object_type, grants in var.schema_objects_grants : [
        for grant in grants :
        grant.on_all && grant.on_future ? [
          merge(
            grant,
            {
              object_type = "${object_type}S",
              on_future   = true,
              on_all      = false
            }
          ),
          merge(
            grant,
            {
              object_type = "${object_type}S",
              on_future   = false,
              on_all      = true
            }
          )
          ] : [
          merge(
            grant,
            {
              object_type = grant.on_all || grant.on_future ? "${object_type}S" : object_type
            }
          )
        ]
      ]
      ]) : "${
      grant.object_type != null && grant.object_name != null ?
      "${grant.object_type}_${grant.database_name}_${grant.schema_name}_${grant.object_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM_${index}"}"
      : ""
      }${
      grant.on_all != null && grant.on_all ?
      "ALL_${grant.object_type}_${grant.database_name}${grant.schema_name != null ? "_${grant.schema_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM_${index}"}" : ""}"
      : ""
      }${
      grant.on_future != null && grant.on_future ?
      "FUTURE_${grant.object_type}_${grant.database_name}${grant.schema_name != null ? "_${grant.schema_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM_${index}"}" : ""}"
      : ""
    }" => grant
  }
}
