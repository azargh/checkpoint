resource "aws_ssm_parameter" "CheckPointToken" {
  name  = "token"
  type  = "String"
  value = "supersecret"
}