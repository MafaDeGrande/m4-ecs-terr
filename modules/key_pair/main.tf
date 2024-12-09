# Key pair
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_openssh
  filename = "tfkey"
}

resource "tls_private_key" "rsa" {
  algorithm = "ED25519"
}
