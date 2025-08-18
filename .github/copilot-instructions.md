# Snowflake Role Terraform Module
A Terraform module for creating and managing Snowflake account roles with various grants and permissions. The module creates roles, assigns grants at account, schema, and schema object levels, and manages role hierarchies.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Validation
- Install required tools:
  ```bash
  # Install Terraform (required version >= 1.3)
  curl -fsSL https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip -o terraform.zip
  unzip terraform.zip && sudo mv terraform /usr/local/bin/ && rm terraform.zip
  
  # Install pre-commit
  pip install pre-commit
  
  # Install tflint
  wget https://github.com/terraform-linters/tflint/releases/download/v0.55.0/tflint_linux_amd64.zip
  unzip tflint_linux_amd64.zip && sudo mv tflint /usr/local/bin/ && rm tflint_linux_amd64.zip
  
  # Install terraform-docs
  curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-linux-amd64.tar.gz
  tar -xzf terraform-docs.tar.gz terraform-docs && sudo mv terraform-docs /usr/local/bin/ && rm terraform-docs.tar.gz
  
  # Install checkov (optional - may fail due to network limitations)
  pip install checkov
  ```

- Validate the main module:
  ```bash
  terraform init    # Takes ~7 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
  terraform validate # Takes ~0.3 seconds.
  terraform fmt -check # Takes ~0.04 seconds.
  tflint            # Takes ~0.07 seconds.
  terraform-docs .  # Takes ~0.05 seconds. Updates README.md files.
  checkov -f . --skip-check CKV_TF_1  # Takes ~6 seconds. May fail due to network limitations.
  ```

- Validate examples:
  ```bash
  # Simple example
  cd examples/simple
  terraform init    # Takes ~9 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
  terraform validate # Takes ~0.3 seconds.
  
  # Complete example  
  cd examples/complete
  terraform init    # Takes ~8 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
  terraform validate # Takes ~0.4 seconds.
  ```

- Run pre-commit hooks:
  ```bash
  pre-commit install # Takes ~0.14 seconds.
  
  # Run individual hooks (full pre-commit may fail due to network issues):
  pre-commit run terraform-validate -a  # Takes ~4 seconds. NEVER CANCEL.
  pre-commit run terraform-fmt -a       # Takes ~0.5 seconds.
  pre-commit run tflint -a              # Takes ~0.7 seconds.
  pre-commit run terraform-docs-go -a   # Takes ~0.2 seconds.
  ```

## Validation Scenarios
- **ALWAYS validate the main module** by running `terraform init && terraform validate` in the repository root
- **ALWAYS test both examples** by running `terraform init && terraform validate` in both `examples/simple/` and `examples/complete/`
- **Manual validation:** Cannot run `terraform plan` without Snowflake credentials, but validation ensures syntax correctness
- **Documentation updates:** Always run `terraform-docs .` before committing to update README.md files
- **Code formatting:** Always run `terraform fmt` before committing

## Build and Test Timing
- **terraform init:** 7-9 seconds (main: 7s, examples: 8-9s). NEVER CANCEL. Set timeout to 60+ seconds minimum.
- **terraform validate:** 0.3-0.4 seconds
- **terraform fmt:** 0.04 seconds
- **tflint:** 0.07 seconds
- **terraform-docs:** 0.05 seconds
- **checkov:** 6+ seconds (may fail due to network limitations - document as "may fail due to firewall restrictions")
- **pre-commit hooks:** 0.2-4 seconds per hook. NEVER CANCEL the terraform-validate hook (takes 4 seconds).

## Common Tasks

### Repository Structure
```
.
├── README.md                    # Module documentation (auto-generated)
├── main.tf                      # Main module resources
├── variables.tf                 # Input variables with validation
├── outputs.tf                   # Module outputs
├── locals.tf                    # Local values and transformations
├── versions.tf                  # Provider version constraints
├── examples/
│   ├── simple/                  # Basic role creation example
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── complete/                # Complex example with multiple grant types
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── versions.tf
│       └── fixtures.tfvars
├── .pre-commit-config.yaml      # Pre-commit hook configuration
├── .terraform-docs.yml          # Terraform-docs configuration
└── .github/
    └── workflows/               # CI/CD workflows
        ├── pre-commit.yml
        ├── pr-title.yml
        └── release.yml
```

### Key Module Features
- **Providers:** Uses snowflake-labs/snowflake provider (>= 0.94) and cloudposse/context provider (>= 0.4.0)
- **Role Management:** Creates snowflake_account_role with configurable naming schemes
- **Grant Types:** Supports account grants, account object grants, schema grants, and schema object grants
- **Role Hierarchy:** Supports granting roles to users, roles, and database roles
- **Context Provider:** Uses context provider for consistent naming conventions

### Important Files to Check After Changes
- Always run `terraform-docs .` after modifying `variables.tf` or `outputs.tf` to update README.md
- Always run `terraform fmt` after any .tf file changes
- Always validate changes don't break the examples: `cd examples/simple && terraform validate` and `cd examples/complete && terraform validate`

### CI/CD Pipeline (.github/workflows/)
- **pre-commit.yml:** Runs terraform validation, formatting, linting, docs generation, and security checks
- **pr-title.yml:** Validates PR titles follow semantic versioning conventions  
- **release.yml:** Creates releases with changelog generation
- All workflows use reusable workflows from `getindata/github-workflows`

### Troubleshooting
- **Provider warnings:** The Snowflake provider shows deprecation warnings about moving to `snowflakedb/snowflake` - this is expected
- **Network timeouts:** Checkov and full pre-commit installation may fail due to network restrictions - this is expected in sandboxed environments
- **Lock file conflicts:** The .terraform.lock.hcl file is gitignored but created during init - this is normal
- **Example fixtures:** The complete example requires fixtures.tfvars file for testing, but can validate without it

### Development Workflow
1. **Make changes** to .tf files
2. **Format code:** `terraform fmt`
3. **Validate syntax:** `terraform validate` 
4. **Test examples:** `cd examples/simple && terraform validate && cd ../complete && terraform validate`
5. **Update docs:** `terraform-docs .`
6. **Lint code:** `tflint`
7. **Run pre-commit:** `pre-commit run terraform-validate -a && pre-commit run terraform-fmt -a`
8. **Commit changes:** Use semantic commit messages (feat:, fix:, docs:, etc.)

The module is ready to use once all validation steps pass. Manual functional testing requires Snowflake credentials and is not possible in this environment.