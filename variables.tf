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

variable "granted_database_roles" {
  description = "Database Roles granted to this role"
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
  description = "Grants on a account level"
  type = list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.account_grants : (grant.privileges != null) != (grant.all_privileges == true)])
    error_message = "Variable `account_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "account_objects_grants" {
  description = <<EOT
  Grants on account object level.
  Account objects list: USER | RESOURCE MONITOR | WAREHOUSE | COMPUTE POOL | DATABASE | INTEGRATION | FAILOVER GROUP | REPLICATION GROUP | EXTERNAL VOLUME
  Object type is used as a key in the map.

  Exmpale usage:

  ```
  account_object_grants = {
    "WAREHOUSE" = [
      {
        all_privileges = true
        with_grant_option = true
        object_name = "TEST_USER"
      }
    ]
    "DATABASE" = [
      {
        privileges = ["CREATE SCHEMA", "CREATE DATABASE ROLE"]
        object_name = "TEST_DATABASE"
      },
      {
        privileges = ["CREATE SCHEMA"]
        object_name = "OTHER_DATABASE"
      }
    ]
  }
  ```

  Note: You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role#nested-schema-for-on_account_object)
  EOT
  type = map(list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
    object_name       = string
  })))
  default = {}
  validation {
    condition     = alltrue([for object_type, grants in var.account_objects_grants : alltrue([for grant in grants : (grant.privileges != null) != (grant.all_privileges != null)])])
    error_message = "Variable `account_objects_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    all_privileges             = optional(bool)
    with_grant_option          = optional(bool, false)
    privileges                 = optional(list(string), null)
    all_schemas_in_database    = optional(bool, false)
    future_schemas_in_database = optional(bool, false)
    database_name              = string
    schema_name                = optional(string, null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.schema_grants : (grant.privileges != null) != (grant.all_privileges == true)])
    error_message = "Variable `schema_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_objects_grants" {
  description = <<EOF
  Grants on a schema object level

  Example usage:

  ```
  schema_objects_grants = {
    "TABLE" = [
      {
        privileges  = ["SELECT"]
        object_name = snowflake_table.table_1.name
        schema_name = snowflake_schema.this.name
      },
      {
        all_privileges = true
        object_name    = snowflake_table.table_2.name
        schema_name    = snowflake_schema.this.name
      }
    ]
    "ALERT" = [
      {
        all_privileges = true
        on_future      = true
        on_all         = true
      }
    ]
  }
  ```

  Note: If you don't provide a schema_name, the grants will be created for all objects of that type in the database.
        You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role#object_type)
  EOF
  type = map(list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool)
    privileges        = optional(list(string))
    object_name       = optional(string)
    on_all            = optional(bool, false)
    schema_name       = optional(string)
    database_name     = string
    on_future         = optional(bool, false)
  })))
  default = {}

  validation {
    condition     = alltrue([for object_type, grants in var.schema_objects_grants : alltrue([for grant in grants : (grant.privileges != null) != (grant.all_privileges != null)])])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }

  validation {
    condition = alltrue([for object_type, grants in var.schema_objects_grants : alltrue([for grant in grants :
      !(grant.object_name != null && (grant.on_all == true || grant.on_future == true))
    ])])
    error_message = "Variable `schema_objects_grants` fails validation - `object_name` cannot be set with `on_all` or `on_future`."
  }
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-role"
}
