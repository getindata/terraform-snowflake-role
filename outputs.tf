output "name" {
  description = "Name of the role"
  value       = one(snowflake_account_role.this[*].name)
}
