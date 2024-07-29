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


<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_grants"></a> [account\_grants](#input\_account\_grants) | Grants on a account level | <pre>list(object({<br>    all_privileges    = optional(bool)<br>    with_grant_option = optional(bool, false)<br>    privileges        = optional(list(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_account_objects_grants"></a> [account\_objects\_grants](#input\_account\_objects\_grants) | Grants on account object level.<br>  Account objects list: USER \| RESOURCE MONITOR \| WAREHOUSE \| COMPUTE POOL \| DATABASE \| INTEGRATION \| FAILOVER GROUP \| REPLICATION GROUP \| EXTERNAL VOLUME<br>  Object type is used as a key in the map.<br><br>  Exmpale usage:<pre>account_object_grants = {<br>    "WAREHOUSE" = [<br>      {<br>        all_privileges = true<br>        with_grant_option = true<br>        object_name = "TEST_USER"<br>      }<br>    ]<br>    "DATABASE" = [<br>      {<br>        privileges = ["CREATE SCHEMA", "CREATE DATABASE ROLE"]<br>        object_name = "TEST_DATABASE"<br>      },<br>      {<br>        privileges = ["CREATE SCHEMA"]<br>        object_name = "OTHER_DATABASE"<br>      }<br>    ]<br>  }</pre>Note: You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role#nested-schema-for-on_account_object) | <pre>map(list(object({<br>    all_privileges    = optional(bool)<br>    with_grant_option = optional(bool, false)<br>    privileges        = optional(list(string), null)<br>    object_name       = string<br>  })))</pre> | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Role description | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_descriptor_name"></a> [descriptor\_name](#input\_descriptor\_name) | Name of the descriptor used to form a resource name | `string` | `"snowflake-role"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_granted_database_roles"></a> [granted\_database\_roles](#input\_granted\_database\_roles) | Database Roles granted to this role | `list(string)` | `[]` | no |
| <a name="input_granted_roles"></a> [granted\_roles](#input\_granted\_roles) | Roles granted to this role | `list(string)` | `[]` | no |
| <a name="input_granted_to_roles"></a> [granted\_to\_roles](#input\_granted\_to\_roles) | Roles which this role is granted to | `list(string)` | `[]` | no |
| <a name="input_granted_to_users"></a> [granted\_to\_users](#input\_granted\_to\_users) | Users which this role is granted to | `list(string)` | `[]` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_role_ownership_grant"></a> [role\_ownership\_grant](#input\_role\_ownership\_grant) | The name of the role to grant ownership | `string` | `null` | no |
| <a name="input_schema_grants"></a> [schema\_grants](#input\_schema\_grants) | Grants on a schema level | <pre>list(object({<br>    all_privileges             = optional(bool)<br>    with_grant_option          = optional(bool, false)<br>    privileges                 = optional(list(string), null)<br>    all_schemas_in_database    = optional(bool, false)<br>    future_schemas_in_database = optional(bool, false)<br>    database_name              = string<br>    schema_name                = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_schema_objects_grants"></a> [schema\_objects\_grants](#input\_schema\_objects\_grants) | Grants on a schema object level<br><br>  Example usage:<pre>schema_objects_grants = {<br>    "TABLE" = [<br>      {<br>        privileges  = ["SELECT"]<br>        object_name = snowflake_table.table_1.name<br>        schema_name = snowflake_schema.this.name<br>      },<br>      {<br>        all_privileges = true<br>        object_name    = snowflake_table.table_2.name<br>        schema_name    = snowflake_schema.this.name<br>      }<br>    ]<br>    "ALERT" = [<br>      {<br>        all_privileges = true<br>        on_future      = true<br>        on_all         = true<br>      }<br>    ]<br>  }</pre>Note: If you don't provide a schema\_name, the grants will be created for all objects of that type in the database.<br>        You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role#object_type) | <pre>map(list(object({<br>    all_privileges    = optional(bool)<br>    with_grant_option = optional(bool)<br>    privileges        = optional(list(string))<br>    object_name       = optional(string)<br>    on_all            = optional(bool, false)<br>    schema_name       = optional(string)<br>    database_name     = string<br>    on_future         = optional(bool, false)<br>  })))</pre> | `{}` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_role_label"></a> [role\_label](#module\_role\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the role |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | ~> 0.94 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | ~> 0.94 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_grant_account_role.granted_roles](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_account_role.granted_to_roles](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_account_role.granted_to_users](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_database_role.granted_db_roles](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_ownership.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_ownership) | resource |
| [snowflake_grant_privileges_to_account_role.account_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.account_object_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.schema_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.schema_objects_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
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
