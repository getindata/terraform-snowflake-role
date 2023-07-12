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
    schema_name   = string
    privileges    = list(string)
  }))
  default = []
}

variable "table_grants" {
  description = "Grants on a table level"
  type = list(object({
    database_name = string
    schema_name   = string
    table_name    = optional(string)
    on_future     = optional(bool)
    privileges    = list(string)
  }))
  default = []
}

variable "external_table_grants" {
  description = "Grants on a external table level"
  type = list(object({
    database_name       = string
    schema_name         = string
    external_table_name = optional(string)
    on_future           = optional(bool)
    privileges          = list(string)
  }))
  default = []
}

variable "view_grants" {
  description = "Grants on a view level"
  type = list(object({
    database_name = string
    schema_name   = string
    view_name     = optional(string)
    on_future     = optional(bool)
    privileges    = list(string)
  }))
  default = []
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-role"
}
