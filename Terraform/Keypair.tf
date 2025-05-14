# creates the key pair to ssh into the instance

resource "aws_key_pair" "key" {
  key_name   = "key"
  # REPLACE KEY BELOW WHEN RUNNING ON YOUR OWN MACHINE
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvebyUUsbarD4cCY/XE8w7s6284mhBK08rDpg/NPpIR Azar@DESKTOP-P7N5F72"
}