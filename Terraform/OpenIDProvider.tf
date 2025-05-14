# this relates to point (1) under Additional Notes in the read me
# and is basically my attempt at finding a way to connect the git hub action runner to the EC2 instance

resource "aws_iam_openid_connect_provider" "github_openid_connect_provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
}