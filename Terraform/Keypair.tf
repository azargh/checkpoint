resource "aws_key_pair" "checkpoint-key" {
  key_name   = "checkpoint-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvebyUUsbarD4cCY/XE8w7s6284mhBK08rDpg/NPpIR Azar@DESKTOP-P7N5F72"
}

resource "aws_key_pair" "github-key" {
  key_name   = "github-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzepIW9QDNDVQM/BKqmLrNCVBWtXkocAX7YxmL5HrMm Azar@DESKTOP-P7N5F72"
}