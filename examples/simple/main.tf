module "snowflake_role" {
  source  = "../../"
  context = module.this.context

  name = "SIMPLE_ROLE"
}
