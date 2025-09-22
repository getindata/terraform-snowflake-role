# AGENTS.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Repository Overview

This is a Terraform module for managing Snowflake account roles with comprehensive grant management capabilities. The module creates roles and supports various types of grants: account-level, account objects, schema-level, and schema objects.

## Key Architecture Patterns

### Context-based Naming System

Use of `context.tf` (terraform CloudPosse `null-label` module) is now deprecated in all our modules, instead CloudPosse's `context` provider should be used. This module implements the standard naming pattern:

1. **Standard variables implementation**:

```hcl
variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "name_scheme" {
  description = <<EOT
  Naming scheme configuration for the resource. This configuration is used to generate names using context provider:
    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`
    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`
    - `context_template_name` - name of the context template used to create the name
    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name
    - `extra_values` - map of extra label-value pairs, used to create a name
    - `uppercase` - convert name to uppercase
  EOT
  type = object({
    properties            = optional(list(string), ["environment", "name"])
    delimiter             = optional(string, "_")
    context_template_name = optional(string, "snowflake-role")
    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")
    extra_values          = optional(map(string))
    uppercase             = optional(bool, true)
  })
  default = {}
}

variable "context_templates" {
  description = "Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration"
  type        = map(string)
  default     = {}
}
```

2. **Resource name creation pattern (locals.tf:1-3, main.tf:1-17)**:

```hcl
locals {
  context_template = lookup(var.context_templates, var.name_scheme.context_template_name, null)
}

data "context_label" "this" {
  delimiter  = local.context_template == null ? var.name_scheme.delimiter : null
  properties = local.context_template == null ? var.name_scheme.properties : null
  template   = local.context_template

  replace_chars_regex = var.name_scheme.replace_chars_regex

  values = merge(
    var.name_scheme.extra_values,
    { name = var.name }
  )
}

resource "snowflake_account_role" "this" {
  name    = var.name_scheme.uppercase ? upper(data.context_label.this.rendered) : data.context_label.this.rendered
  comment = var.comment
}
```

3. **Sample provider configuration**:

```hcl
provider "context" {
  properties = {
    "environment" = {}
    "name"        = {}
  }
  values = {
    environment = "dev"
  }
}
```

4. **Sample tfvars with context templates**:

```hcl
context_templates = {
  snowflake-role              = "{{.environment}}_{{.name}}"
  snowflake-project-warehouse = "{{.environment}}_{{.project}}_{{.name}}"
  snowflake-warehouse         = "{{.environment}}_{{.name}}"
  snowflake-warehouse-role    = "{{.prefix}}_{{.environment}}_{{.warehouse}}_{{.name}}"
}
```

### Complex Grant Processing Architecture

The module's core complexity lies in `locals.tf` which transforms user-friendly variables into resource-specific configurations:

1. **Grant flattening and key generation (locals.tf:4-90)**: Converts nested maps/lists into flat structures with unique keys for `for_each` loops
2. **Object type handling**: Manages pluralization for collection-based grants (`TABLE` → `TABLES`)
3. **Edge case processing**: Handles combinations like `on_all` + `on_future` by creating separate resources
4. **Validation integration**: Works with variable validation blocks to ensure proper grant configuration

## Common Development Commands

### Terraform Operations

```bash
# Initialize and validate
terraform init
terraform validate

# Format and plan
terraform fmt -recursive
terraform plan

# Apply changes
terraform apply
```

### Pre-commit Hooks

```bash
# Install hooks
pre-commit install

# Run all hooks
pre-commit run --all-files

# Run specific validations
pre-commit run terraform-validate
pre-commit run terraform-fmt
pre-commit run tflint
pre-commit run terraform-docs
pre-commit run checkov
```

### Linting and Security

```bash
# Run TFLint with custom config
tflint --config=.tflint.hcl

# Security scanning
checkov -d . --skip-check CKV_TF_1
```

## Pre-commit Configuration

Comprehensive pre-commit hooks configured in `.pre-commit-config.yaml`:

- `terraform-validate` - Validates configuration (runs terraform init first)
- `terraform-fmt` - Formats code
- `tflint` - Linting with custom config
- `terraform-docs` - Auto-generates documentation
- `checkov` - Security scanning (skips CKV_TF_1 for module sources)
- Standard Git hooks (merge conflict detection, YAML validation, EOF fixing)

## Grant Types and Usage Patterns

### Account Grants
Global-level privileges affecting the entire Snowflake account:
```hcl
account_grants = [
  {
    privileges = ["CREATE DATABASE", "CREATE ROLE"]
  }
]
```

### Account Object Grants
Resource-specific privileges on account-level objects:
```hcl
account_objects_grants = {
  "DATABASE" = [
    {
      privileges  = ["USAGE", "CREATE SCHEMA"]
      object_name = "ANALYTICS_DB"
    }
  ]
  "WAREHOUSE" = [
    {
      all_privileges = true
      object_name    = "COMPUTE_WH"
    }
  ]
}
```

### Schema Grants
Schema-level access with support for all/future schemas:
```hcl
schema_grants = [
  {
    database_name              = "ANALYTICS_DB"
    schema_name                = "RAW"
    privileges                 = ["USAGE", "CREATE TABLE"]
    all_schemas_in_database    = false
    future_schemas_in_database = true
  }
]
```

### Schema Object Grants
Fine-grained control over tables, views, functions, etc.:
```hcl
schema_objects_grants = {
  "TABLE" = [
    {
      database_name = "ANALYTICS_DB"
      schema_name   = "RAW"
      on_all        = true
      on_future     = true
      privileges    = ["SELECT", "INSERT"]
    }
  ]
}
```

### Application Role Grants
Grant application roles to the account role:
```hcl
granted_application_roles = [
  "SNOWFLAKE.BUDGET_VIEWER",
  "SNOWFLAKE.COST_INSIGHTS_USER",
  "MY_APP.CUSTOM_ROLE"
]
```

**Common Snowflake System Application Roles:**
- `SNOWFLAKE.BUDGET_VIEWER` - View budget and spending information
- `SNOWFLAKE.COST_INSIGHTS_USER` - Access cost insights and analytics

**Format**: Application role names use dot notation: `APPLICATION_NAME.ROLE_NAME`

## Breaking Changes History

- **v2.x**: Migrated from deprecated provider resources (`snowflake_role` → `snowflake_account_role`)
- **v3.x**: Replaced nulllabel `context.tf` with CloudPosse `context` provider
- **v4.x**: Updated for Snowflake provider source rename (`Snowflake-Labs/snowflake` → `snowflakedb/snowflake`)

## Validation Rules

The module enforces several validation constraints in `variables.tf`:

1. **Mutual exclusion**: `privileges` and `all_privileges` cannot both be set
2. **Object targeting**: `object_name` cannot be used with `on_all`/`on_future` flags
3. **Required fields**: `database_name` required for schema object grants

## Dependencies

- Terraform >= 1.3
- Snowflake provider >= 0.94 (snowflakedb/snowflake)
- Context provider >= 0.4.0 (cloudposse/context)

## Development Hints

- Always use terraform mcp server to download most up-to-date documentation and versions
- Try to use Context7 mcp server to get information about additional libraries
- Always use `getindata` modules if available instead of unknown modules or raw resources
- Always save context / information to AGENTS.md (do not use CLAUDE.md for that)
- Always use terraform best practices when creating code, planning and reviewing
- Always check and fix lining of terraform code that was generated according to best practices and built-in `terraform fmt` command
- **Context Provider Best Practices**:
  - Keep naming logic in context provider and templates, avoid hardcoded values in resources
  - Use single `extra_values` source to avoid configuration duplication
  - Set complex naming values in the context provider, not in module logic

## Recent Context and Updates

### Application Role Granting Implementation (2025-01-22)

Successfully added application role granting capability to the terraform-snowflake-role module:

**Changes Made:**

1. **Added `granted_application_roles` variable** (variables.tf:30-34): New list(string) variable following same pattern as database roles
2. **Implemented `snowflake_grant_application_role` resource** (main.tf:62-67): Uses for_each pattern consistent with existing role grants
3. **Updated complete example** (examples/complete/main.tf:72-75): Added practical examples using Snowflake system roles
4. **Enhanced documentation**: Updated README.md and AGENTS.md with application role usage patterns
5. **Fixed provider configuration** (examples/complete/providers.tf): Added preview features for table and dynamic table resources

**Key Implementation Details:**

- Resource: `snowflake_grant_application_role` from snowflakedb/snowflake provider
- Pattern: Follows exact same approach as `granted_database_roles` for consistency
- Format: Application role names use dot notation (e.g., `APPLICATION_NAME.ROLE`)
- Examples use built-in Snowflake system roles that work without additional setup:
  - `SNOWFLAKE.BUDGET_VIEWER` - View budget and spending information
  - `SNOWFLAKE.COST_INSIGHTS_USER` - Access cost insights and analytics

**Technical Notes:**

- Preview features required: `snowflake_table_resource`, `snowflake_dynamic_table_resource`
- Application role names should follow `APPLICATION_NAME.ROLE_NAME` format
- Implementation maintains backward compatibility and follows established module patterns
