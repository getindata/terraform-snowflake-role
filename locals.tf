locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

}
