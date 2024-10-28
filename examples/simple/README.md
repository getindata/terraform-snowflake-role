# Simple example

This is simple usage example of `snowflake-role` terraform module.

## How to plan

```shell
terraform init
terraform plan
```

## How to apply

```shell
terraform init
terraform apply
```

## How to destroy

```shell
terraform destroy
```


<!-- BEGIN_TF_DOCS -->




## Inputs

No inputs.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snowflake_role"></a> [snowflake\_role](#module\_snowflake\_role) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_role_output"></a> [snowflake\_role\_output](#output\_snowflake\_role\_output) | Snowflake role outputs |

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
| [snowflake_database.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database) | resource |
<!-- END_TF_DOCS -->
