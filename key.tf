resource "tls_private_key" "key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo \"${tls_private_key.key.private_key_pem}\" >/tmp/id && chmod 0600 /tmp/id"
  }
}

locals {
  private_key      = "${tls_private_key.key.private_key_pem}"
  private_key_file = "/tmp/id"
  public_key       = "${tls_private_key.key.public_key_openssh}"
}
