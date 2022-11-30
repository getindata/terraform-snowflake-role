output "name" {
  description = "Name of the role"
  value       = one(snowflake_role.this[*].name)
}
