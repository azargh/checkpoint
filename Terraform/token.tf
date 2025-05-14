# creates the secret token and stores it in the SSM
resource "aws_ssm_parameter" "CheckPointToken" {
  name  = "token"
  type  = "String"
  # Change the token below
  value = "supersecret"
}