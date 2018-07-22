variable "scaleway_organization_id" {}

variable "scaleway_secret_key" {}

variable "scaleway_region" {
  default = "ams1"
}

provider "scaleway" {
  organization = "${var.scaleway_organization_id}"
  token        = "${var.scaleway_secret_key}"
  region       = "${var.scaleway_region}"
}

data "scaleway_image" "debian_9" {
  architecture = "x86_64"
  name         = "Debian Stretch"
}

resource "scaleway_ip" "bench" {}

resource "scaleway_security_group" "bench" {
  name                    = "bench"
  description             = "Benchmark security group"
  enable_default_security = false
}

resource "scaleway_security_group_rule" "bench_ssh" {
  security_group = "${scaleway_security_group.bench.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 22
}

resource "scaleway_server" "bench" {
  name  = "bench"
  image = "${data.scaleway_image.debian_9.id}"
  type  = "VC1S"

  public_ip      = "${scaleway_ip.bench.ip}"
  security_group = "${scaleway_security_group.bench.id}"

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y html-xml-utils wget jq",
    ]
  }

  provisioner "remote-exec" {
    script = "./provisions/geekbench.sh"
  }

  provisioner "local-exec" {
    command = "mkdir -p ./logs/scaleway && scp -r -o StrictHostKeyChecking=no root@${scaleway_server.bench.public_ip}:/var/log/geekbench ./logs/scaleway"
  }
}

output "scaleway_server_ip" {
  value = "${scaleway_server.bench.public_ip}"
}

data "external" "scaleway" {
  program    = ["cat", "./logs/scaleway/geekbench/result.json"]
  depends_on = ["scaleway_server.bench"]
}

output "scaleway" {
  value = "${data.external.scaleway.result}"
}
