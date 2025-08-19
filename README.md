# Snowflake Role Terraform Module

![Snowflake](https://img.shields.io/badge/-SNOWFLAKE-249edc?style=for-the-badge&logo=snowflake&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

![License](https://badgen.net/github/license/getindata/terraform-snowflake-role/)
![Release](https://badgen.net/github/release/getindata/terraform-snowflake-role/)

<p align="center">
  <img height="150" src="https://getindata.com/img/logo.svg">
  <h3 align="center">We help companies turn their data into assets</h3>
</p>

---

Terraform module for managing Snowflake roles. 
Additionally, this module allows creating multiple grants on different Snowflake resources, specifying other roles to be granted and grantees (other roles and users).

## USAGE

```terraform
module "snowflake_role" {
  source = "github.com/getindata/terraform-snowflake-role"
  
  name = "LOGS_DATABASE_READER"

  granted_to_users = ["JANE_SMITH", "JOHN_DOE"]

 account_grants = [
    {
      privileges = ["CREATE DATABASE"]
    }
  ]

  account_objects_grants = {
    "DATABASE" = [
      {
        privileges    = ["USAGE"]
        object_name    = "LOGS_DB"
      }
    ]
  }

  schema_grants = [
    {
      database_name = "LOGS_DB"
      schema_name   = "BRONZE"
      privileges    = ["USAGE"]
    }
  ]
  
  schema_objects_grants = {
    TABLE = [
      {
        database_name = "LOGS_DB"
        schema_name   = "BRONZE"
        on_future     = true
        privileges    = ["SELECT"]
      }
    ]

    VIEW = [
      {
        database_name  = snowflake_database.this.name
        on_future      = true
        all_privileges = true
      }
    ]
  }
}
```

## EXAMPLES

- [Simple](examples/simple) - creates a role
- [Complete](examples/complete) - creates a role with example grants

## Breaking changes in v2.x of the module

Due to breaking changes in Snowflake provider and additional code optimizations, **breaking changes** were introduced in `v2.0.0` version of this module.

List of code and variable (API) changes:

- Switched to `snowflake_account_role` resource instead of provider-deprecated `snowflake_role`
- Switched to `snowflake_grant_privileges_to_account_role` resource instead of provider-removed `snowflake_*_grant`
- Switched to `snowflake_grant_account_role` resource instead of provider-removed `snowflake_role_grants`
- Switched to `snowflake_grant_ownership` resource instead of provider-removed `snowflake_role_ownership_grant`
- Variable `account_grants` type changed from `list(string)` to `list(object({..}))`
- Variable `schema_grants` type changed
- Below variables were removed and replaced with aggregated / complex `account_object_grants` and `schema_object_grants`:
  - `database_grants`
  - `table_grants`
  - `external_table_grants`
  - `view_grants`
  - `dynamic_table_grants`

When upgrading from `v1.x`, expect most of the resources to be recreated - if recreation is impossible, then it is possible to import some existing resources.

For more information, refer to [variables.tf](variables.tf), list of inputs below and Snowflake provider documentation

## Breaking changes in v3.x of the module

Due to replacement of nulllabel (`context.tf`) with context provider, some **breaking changes** were introduced in `v3.0.0` version of this module.

List od code and variable (API) changes:

- Removed `context.tf` file (a single-file module with additonal variables), which implied a removal of all its variables (except `name`):
  - `descriptor_formats`
  - `label_value_case`
  - `label_key_case`
  - `id_length_limit`
  - `regex_replace_chars`
  - `label_order`
  - `additional_tag_map`
  - `tags`
  - `labels_as_tags`
  - `attributes`
  - `delimiter`
  - `stage`
  - `environment`
  - `tenant`
  - `namespace`
  - `enabled`
  - `context`
- Remove support `enabled` flag - that might cause some backward compatibility issues with terraform state (please take into account that proper `move` clauses were added to minimize the impact), but proceed with caution
- Additional `context` provider configuration
- New variables were added, to allow naming configuration via `context` provider:
  - `context_templates`
  - `name_schema`

## Breaking changes in v4.x of the module

Due to rename of Snowflake terraform provider source, all `versions.tf` files were updated accordingly.

Please keep in mind to mirror this change in your own repos also.

For more information about provider rename, refer to [Snowflake documentation](https://github.com/snowflakedb/terraform-provider-snowflake/blob/main/SNOWFLAKEDB_MIGRATION.md).

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_grants"></a> [account\_grants](#input\_account\_grants) | Grants on a account level | <pre>list(object({<br/>    all_privileges    = optional(bool)<br/>    with_grant_option = optional(bool, false)<br/>    privileges        = optional(list(string), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_account_objects_grants"></a> [account\_objects\_grants](#input\_account\_objects\_grants) | Grants on account object level.<br/>  Account objects list: USER \| RESOURCE MONITOR \| WAREHOUSE \| COMPUTE POOL \| DATABASE \| INTEGRATION \| FAILOVER GROUP \| REPLICATION GROUP \| EXTERNAL VOLUME<br/>  Object type is used as a key in the map.<br/><br/>  Exmpale usage:<pre>account_object_grants = {<br/>    "WAREHOUSE" = [<br/>      {<br/>        all_privileges = true<br/>        with_grant_option = true<br/>        object_name = "TEST_USER"<br/>      }<br/>    ]<br/>    "DATABASE" = [<br/>      {<br/>        privileges = ["CREATE SCHEMA", "CREATE DATABASE ROLE"]<br/>        object_name = "TEST_DATABASE"<br/>      },<br/>      {<br/>        privileges = ["CREATE SCHEMA"]<br/>        object_name = "OTHER_DATABASE"<br/>      }<br/>    ]<br/>  }</pre>Note: You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role#nested-schema-for-on_account_object) | <pre>map(list(object({<br/>    all_privileges    = optional(bool)<br/>    with_grant_option = optional(bool, false)<br/>    privileges        = optional(list(string), null)<br/>    object_name       = string<br/>  })))</pre> | `{}` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Role description | `string` | `null` | no |
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration | `map(string)` | `{}` | no |
| <a name="input_granted_database_roles"></a> [granted\_database\_roles](#input\_granted\_database\_roles) | Database Roles granted to this role | `list(string)` | `[]` | no |
| <a name="input_granted_roles"></a> [granted\_roles](#input\_granted\_roles) | Roles granted to this role | `list(string)` | `[]` | no |
| <a name="input_granted_to_roles"></a> [granted\_to\_roles](#input\_granted\_to\_roles) | Roles which this role is granted to | `list(string)` | `[]` | no |
| <a name="input_granted_to_users"></a> [granted\_to\_users](#input\_granted\_to\_users) | Users which this role is granted to | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_name_scheme"></a> [name\_scheme](#input\_name\_scheme) | Naming scheme configuration for the resource. This configuration is used to generate names using context provider:<br/>    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`<br/>    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`<br/>    - `context_template_name` - name of the context template used to create the name<br/>    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name<br/>    - `extra_values` - map of extra label-value pairs, used to create a name<br/>    - `uppercase` - convert name to uppercase | <pre>object({<br/>    properties            = optional(list(string), ["environment", "name"])<br/>    delimiter             = optional(string, "_")<br/>    context_template_name = optional(string, "snowflake-role")<br/>    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")<br/>    extra_values          = optional(map(string))<br/>    uppercase             = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_role_ownership_grant"></a> [role\_ownership\_grant](#input\_role\_ownership\_grant) | The name of the role to grant ownership | `string` | `null` | no |
| <a name="input_schema_grants"></a> [schema\_grants](#input\_schema\_grants) | Grants on a schema level | <pre>list(object({<br/>    all_privileges             = optional(bool)<br/>    with_grant_option          = optional(bool, false)<br/>    privileges                 = optional(list(string), null)<br/>    all_schemas_in_database    = optional(bool, false)<br/>    future_schemas_in_database = optional(bool, false)<br/>    database_name              = string<br/>    schema_name                = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_schema_objects_grants"></a> [schema\_objects\_grants](#input\_schema\_objects\_grants) | Grants on a schema object level<br/><br/>  Example usage:<pre>schema_objects_grants = {<br/>    "TABLE" = [<br/>      {<br/>        privileges  = ["SELECT"]<br/>        object_name = snowflake_table.table_1.name<br/>        schema_name = snowflake_schema.this.name<br/>      },<br/>      {<br/>        all_privileges = true<br/>        object_name    = snowflake_table.table_2.name<br/>        schema_name    = snowflake_schema.this.name<br/>      }<br/>    ]<br/>    "ALERT" = [<br/>      {<br/>        all_privileges = true<br/>        on_future      = true<br/>        on_all         = true<br/>      }<br/>    ]<br/>  }</pre>Note: If you don't provide a schema\_name, the grants will be created for all objects of that type in the database.<br/>        You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role#object_type) | <pre>map(list(object({<br/>    all_privileges    = optional(bool)<br/>    with_grant_option = optional(bool)<br/>    privileges        = optional(list(string))<br/>    object_name       = optional(string)<br/>    on_all            = optional(bool, false)<br/>    schema_name       = optional(string)<br/>    database_name     = string<br/>    on_future         = optional(bool, false)<br/>  })))</pre> | `{}` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the role |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_context"></a> [context](#provider\_context) | >=0.4.0 |
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.94 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.94 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.this](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_grant_account_role.granted_roles](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_account_role.granted_to_roles](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_account_role.granted_to_users](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_database_role.granted_db_roles](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_ownership.this](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_ownership) | resource |
| [snowflake_grant_privileges_to_account_role.account_grants](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.account_object_grants](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.schema_grants](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.schema_objects_grants](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [context_label.this](https://registry.terraform.io/providers/cloudposse/context/latest/docs/data-sources/label) | data source |
<!-- END_TF_DOCS -->

## CONTRIBUTING

Contributions are very welcomed!

Start by reviewing [contribution guide](CONTRIBUTING.md) and our [code of conduct](CODE_OF_CONDUCT.md). After that, start coding and ship your changes by creating a new PR.

## LICENSE

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.

## AUTHORS

<!--- Replace repository name -->
<a href="https://github.com/getindata/terraform-snowflake-role/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=getindata/terraform-snowflake-role" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
