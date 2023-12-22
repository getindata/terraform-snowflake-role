variable "comment" {
  description = "Role description"
  type        = string
  default     = null
}

variable "role_ownership_grant" {
  description = "The name of the role to grant ownership"
  type        = string
  default     = null
}

variable "granted_roles" {
  description = "Roles granted to this role"
  type        = list(string)
  default     = []
}

variable "granted_to_roles" {
  description = "Roles which this role is granted to"
  type        = list(string)
  default     = []
}

variable "granted_to_users" {
  description = "Users which this role is granted to"
  type        = list(string)
  default     = []
}

variable "account_grants" {
  description = "Grants on an account level"
  type        = list(string)
  default     = []
}

variable "database_grants" {
  description = "Grants on a database level"
  type = list(object({
    database_name = string
    privileges    = list(string)
  }))
  default = []
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    database_name = string
    schema_name   = optional(string)
    privileges    = list(string)
    on_all        = optional(bool)
    on_future     = optional(bool)
  }))
  default = []
  validation {
    condition     = alltrue([for schema_grant in var.schema_grants : anytrue([schema_grant.schema_name != null, schema_grant.on_future, schema_grant.on_all])])
    error_message = "Variable `schema_grants` fails validation - ne of `schema_name`, `on_future` or `on_all` has to be set (not null / true)."
  }
}

variable "table_grants" {
  description = "Grants on a table level"
  type = list(object({
    database_name = string
    schema_name   = string
    table_name    = optional(string)
    on_future     = optional(bool)
    on_all        = optional(bool)
    privileges    = list(string)
  }))
  default = []
  validation {
    condition     = alltrue([for table_grant in var.table_grants : anytrue([table_grant.table_name != null, table_grant.on_future, table_grant.on_all])])
    error_message = "Variable `table_grants` fails validation - one of `table_name`, `on_future` or `on_all` has to be set (not null / true)."
  }
}

variable "external_table_grants" {
  description = "Grants on a external table level"
  type = list(object({
    database_name       = string
    schema_name         = string
    external_table_name = optional(string)
    on_future           = optional(bool)
    on_all              = optional(bool)
    privileges          = list(string)
  }))
  default = []
  validation {
    condition     = alltrue([for external_table_grant in var.external_table_grants : anytrue([external_table_grant.external_table_name != null, external_table_grant.on_future, external_table_grant.on_all])])
    error_message = "Variable `external_table_grants` fails validation - one of `external_table_name`, `on_future` or `on_all` has to be set (not null / true)."
  }
}

variable "view_grants" {
  description = "Grants on a view level"
  type = list(object({
    database_name = string
    schema_name   = string
    view_name     = optional(string)
    on_future     = optional(bool)
    on_all        = optional(bool)
    privileges    = list(string)
  }))
  default = []
  validation {
    condition     = alltrue([for view_grant in var.view_grants : anytrue([view_grant.view_name != null, view_grant.on_future, view_grant.on_all])])
    error_message = "Variable `view_grants` fails validation - one of `view_name`, `on_future` or `on_all` has to be set (not null / true)."
  }
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-role"
}
