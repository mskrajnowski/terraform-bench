variable "hcloud_token" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "bench" {
  name       = "bench"
  public_key = "${local.public_key}"
}

resource "hcloud_server" "bench" {
  name        = "bench"
  server_type = "cx11"
  image       = "debian-9"
  location    = "nbg1"

  ssh_keys = [
    "${hcloud_ssh_key.bench.name}",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${local.private_key}"
    agent       = false
  }

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
    command = "mkdir -p ./logs/hcloud && scp -r -i ${local.private_key_file} -o StrictHostKeyChecking=no root@${hcloud_server.bench.ipv4_address}:/var/log/geekbench ./logs/hcloud"
  }
}

output "hcloud_server_ip" {
  value = "${hcloud_server.bench.ipv4_address}"
}

data "external" "hcloud" {
  program    = ["cat", "./logs/hcloud/geekbench/result.json"]
  depends_on = ["hcloud_server.bench"]
}

output "hcloud" {
  value = "${data.external.hcloud.result}"
}
