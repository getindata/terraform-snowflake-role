# Complete example

This is complete usage example of `snowflake-role` terraform module.

## How to plan

```shell
terraform init
terraform plan -var-file=fixtures.tfvars
```

## How to apply

```shell
terraform init
terraform apply -var-file=fixtures.tfvars
```

## How to destroy

```shell
terraform destroy -var-file=fixtures.tfvars
```

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | A map of context templates to use for generating user names | `map(string)` | n/a | yes |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snowflake_role_1"></a> [snowflake\_role\_1](#module\_snowflake\_role\_1) | ../../ | n/a |
| <a name="module_snowflake_role_2"></a> [snowflake\_role\_2](#module\_snowflake\_role\_2) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_role_1"></a> [snowflake\_role\_1](#output\_snowflake\_role\_1) | Snowflake role outputs |
| <a name="output_snowflake_role_2"></a> [snowflake\_role\_2](#output\_snowflake\_role\_2) | Snowflake role outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | ~> 0.94 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | ~> 0.94 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.role_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_account_role.role_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_database.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database) | resource |
| [snowflake_database_role.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_dynamic_table.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/dynamic_table) | resource |
| [snowflake_schema.schema_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
| [snowflake_schema.schema_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
| [snowflake_table.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) | resource |
| [snowflake_user.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/user) | resource |
| [snowflake_warehouse.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/warehouse) | resource |
<!-- END_TF_DOCS -->
