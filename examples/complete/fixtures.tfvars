namespace = "gid"
stage     = "example"

descriptor_formats = {
  snowflake-role = {
    labels = ["attributes", "name"]
    format = "%v_%v_ROLE"
  }
}

tags = {
  Terraform = "True"
}
