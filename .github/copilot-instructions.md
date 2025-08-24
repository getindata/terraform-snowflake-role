# GitHub Copilot Review Instructions

This document provides guidance for GitHub Copilot when reviewing code changes in the terraform-snowflake-role repository.

## Repository Overview

This is a Terraform module for managing Snowflake account roles with comprehensive grant management capabilities. The module creates and configures Snowflake roles with various types of privileges on account, database, schema, and object levels.

## Key Components to Review

### 1. Terraform Code Structure
- **main.tf**: Contains primary resource definitions for Snowflake roles and grants
- **variables.tf**: Input variable definitions with validation rules
- **outputs.tf**: Module output definitions
- **locals.tf**: Local value computations for complex grant mappings
- **versions.tf**: Provider version constraints

### 2. Critical Review Areas

#### Variable Validation
- Ensure all variables have proper validation blocks where appropriate
- Check that mutually exclusive options (e.g., `privileges` vs `all_privileges`) are properly validated
- Verify that complex object variables have proper type definitions
- Validate that required fields in object types are marked appropriately

#### Security and Permissions
- **CRITICAL**: Review any changes to grant configurations for security implications
- Ensure proper privilege escalation controls
- Check that `with_grant_option` is used judiciously
- Verify that role hierarchies are logical and secure
- Ensure database and schema names are properly quoted in grant statements

#### Naming Conventions
- Verify that the context provider integration is maintained
- Check that naming scheme variables (`name_scheme`, `context_templates`) are used correctly
- Ensure generated role names follow Snowflake naming conventions
- Validate that `uppercase` setting is respected

#### Resource Dependencies
- Check that resource dependencies are properly defined
- Ensure `moved` blocks are appropriate for resource refactoring
- Verify that `for_each` and `count` usage is optimal

### 3. Code Quality Standards

#### Terraform Best Practices
- Use consistent formatting (terraform fmt should pass)
- Ensure proper resource naming and organization
- Check for unnecessary resource recreation
- Validate that outputs provide meaningful information

#### Documentation
- Ensure all variables have clear descriptions
- Check that complex variable types include usage examples
- Verify that README.md reflects any variable changes
- Ensure examples in `/examples` directory are updated accordingly

#### Testing Considerations
- Verify that changes don't break existing example configurations
- Check that new variables have appropriate defaults
- Ensure backward compatibility where possible

### 4. Snowflake-Specific Patterns

#### Grant Management Hierarchy
- **Account grants**: Global privileges on the Snowflake account (e.g., CREATE DATABASE)
- **Account object grants**: Privileges on account-level objects (databases, warehouses, etc.)
- **Schema grants**: Privileges on schemas within databases (can target all/future schemas)
- **Schema object grants**: Privileges on objects within schemas (tables, views, etc.)

#### Local Value Patterns
Review the complex local value computations in `locals.tf`:
- Grant mappings must create unique keys for Terraform's for_each
- Object type pluralization for `on_all` and `on_future` grants (TABLE → TABLES)
- Conditional grant splitting when both `on_all` and `on_future` are specified
- Proper key generation for grant identification

#### Validation Patterns
```hcl
# Example of proper variable validation
validation {
  condition = alltrue([
    for object_type, grants in var.schema_objects_grants : 
    alltrue([
      for grant in grants : 
      (grant.privileges != null) != (grant.all_privileges != null)
    ])
  ])
  error_message = "Only one of `privileges` or `all_privileges` can be set."
}
```

#### Resource Patterns to Validate
```hcl
# Proper grant structure validation
resource "snowflake_grant_privileges_to_account_role" "example" {
  account_role_name = snowflake_account_role.this.name
  # Ensure either privileges OR all_privileges, never both
  privileges        = var.specific_privileges
  all_privileges    = var.use_all_privileges
}

# Proper schema object identifier quoting
on_schema_object {
  object_name = "\"${each.value.database_name}\".\"${each.value.schema_name}\".\"${each.value.object_name}\""
}

# Correct context provider usage
data "context_label" "this" {
  template   = local.context_template
  properties = local.context_template == null ? var.name_scheme.properties : null
  delimiter  = local.context_template == null ? var.name_scheme.delimiter : null
}
```

#### Common Anti-Patterns to Flag
- Using both `privileges` and `all_privileges` in the same grant
- Setting `object_name` together with `on_all` or `on_future`
- Missing validation for mutually exclusive options
- Hardcoded values that should use variables
- Improper quoting of Snowflake identifiers (should use double quotes)
- Missing `depends_on` for resources that reference other module outputs
- Incorrect local value computations that could cause resource recreation
- Object type pluralization errors (TABLE vs TABLES for on_all/on_future grants)

### 5. Breaking Changes to Monitor

This module has undergone significant evolution. When reviewing changes, be especially careful about:

#### Version 3.x Breaking Changes (Context Provider Migration)
- Removed `context.tf` file and all nulllabel variables
- Introduced `context_templates` and `name_scheme` variables
- Added context provider dependency
- Removed `enabled` flag support

#### Version 2.x Breaking Changes (Provider Updates)
- Migration from deprecated Snowflake provider resources:
  - `snowflake_role` → `snowflake_account_role`
  - `snowflake_*_grant` → `snowflake_grant_privileges_to_account_role`
  - `snowflake_role_grants` → `snowflake_grant_account_role`
- Variable structure changes:
  - `account_grants`: `list(string)` → `list(object({...}))`
  - Consolidated multiple grant variables into `account_object_grants` and `schema_object_grants`

#### Review Criteria for Breaking Changes
- Variable type changes that could break existing configurations
- Resource attribute modifications that force recreation
- Changes to default values that alter existing behavior
- Provider version updates that introduce breaking changes
- Removal of deprecated variables or resources

### 6. Documentation Requirements

For any changes involving:
- **New variables**: Update README.md using terraform-docs (automated via pre-commit)
- **New functionality**: Add usage examples to `/examples` directory
- **Breaking changes**: Update changelog and migration guides in README.md
- **Variable modifications**: Regenerate terraform-docs output
- **Complex variable types**: Include usage examples in variable descriptions

#### Terraform-docs Integration
- This repository uses terraform-docs with automated README generation
- Documentation is injected between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers
- Pre-commit hooks automatically update documentation
- Ensure variable descriptions are clear and include examples for complex types

#### Migration Pattern
When refactoring resources, use `moved` blocks to maintain Terraform state continuity:
```hcl
moved {
  from = old_resource_name[0]
  to   = new_resource_name
}
```

## Review Checklist

When reviewing pull requests, ensure:

- [ ] Terraform code follows HCL best practices
- [ ] All variables have appropriate validation rules
- [ ] Security implications of grant changes are considered
- [ ] Naming conventions are consistently applied via context provider
- [ ] Documentation is updated for any API changes
- [ ] Examples are updated to reflect new functionality
- [ ] No hardcoded values where variables should be used
- [ ] Resource dependencies are properly managed
- [ ] Backward compatibility is maintained where possible
- [ ] Pre-commit hooks would pass (terraform fmt, validation, etc.)
- [ ] Context templates are properly utilized when provided
- [ ] Local value computations maintain unique keys for for_each loops
- [ ] Grant configurations follow the established patterns

## Context Provider Integration

This module uses the CloudPosse context provider for consistent naming. Key points:

- `context_templates` variable takes precedence over `name_scheme.properties` and `name_scheme.delimiter`
- The context label data source generates the final role name
- `name_scheme.uppercase` controls whether the final name is uppercase
- Context templates should follow the pattern defined in the provider configuration
- Extra values can be passed through `name_scheme.extra_values`

Example context provider usage:
```hcl
provider "context" {
  properties = {
    "environment" = {}
    "name"        = { required = true }
    "project"     = {}
  }
  
  values = {
    environment = "DEV"
  }
}
```

## Security Considerations

Pay special attention to:
- Privilege escalation through role grants
- Overly broad permissions (prefer specific privileges over `all_privileges`)
- Grant options that allow further privilege delegation
- User and role assignments that might violate security policies
- Database and schema access patterns

## Performance Considerations

Review for:
- Efficient use of `for_each` vs `count`
- Proper resource grouping to minimize Snowflake API calls
- Appropriate use of local values for complex computations
- Resource dependencies that don't cause unnecessary ordering constraints

## Pre-commit and CI/CD Integration

This repository uses pre-commit hooks and GitHub Actions:

### Pre-commit Hooks
- `terraform-validate`: Validates Terraform configuration
- `terraform-fmt`: Formats Terraform code
- `tflint`: Lints Terraform code for errors and best practices
- `terraform-docs-go`: Automatically updates documentation
- `checkov`: Security and compliance scanning
- Various file quality checks (merge conflicts, YAML validity, etc.)

### GitHub Workflows
- **PR Title Validation**: Ensures semantic commit message format
- **Pre-commit**: Runs all pre-commit hooks on pull requests
- **Release**: Automated release management

### Review Guidelines for CI/CD Changes
- Ensure new code passes all pre-commit hooks
- Maintain semantic commit message format (feat:, fix:, docs:, etc.)
- Consider impact on automated releases
- Verify that checkov security scans pass with appropriate skip rules if needed

## Module Usage Patterns

Review these common usage patterns:

### Basic Role Creation
```hcl
module "simple_role" {
  source = "github.com/getindata/terraform-snowflake-role"
  name   = "READER_ROLE"
}
```

### Role with Context Provider
```hcl
module "contextual_role" {
  source            = "github.com/getindata/terraform-snowflake-role"
  name              = "reader"
  context_templates = var.context_templates
  
  name_scheme = {
    context_template_name = "snowflake-project-role"
    extra_values = {
      project = "analytics"
    }
  }
}
```

### Complex Grant Configuration
```hcl
module "complex_role" {
  source = "github.com/getindata/terraform-snowflake-role"
  name   = "ANALYST_ROLE"
  
  # Account-level privileges
  account_grants = [{
    privileges = ["CREATE DATABASE"]
  }]
  
  # Database access
  account_objects_grants = {
    "DATABASE" = [{
      privileges  = ["USAGE"]
      object_name = "ANALYTICS_DB"
    }]
  }
  
  # Schema object access with future grants
  schema_objects_grants = {
    "TABLE" = [{
      database_name = "ANALYTICS_DB"
      schema_name   = "RAW"
      on_future     = true
      privileges    = ["SELECT"]
    }]
  }
}
```