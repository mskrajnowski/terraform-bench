# Bench

Terraform-based VPS benchmark tool

## Benchmarks

- [Geekbench 4](https://www.geekbench.com/)

## Providers

- [Hetzner Cloud](https://www.hetzner.com/cloud)

## Usage

1.  Install [terraform](https://www.terraform.io/downloads.html)
2.  Create a `terraform.tfvars` with necessary credentials, by copying `terraform.tfvars.template` and filling the blanks
3.  `$ terraform init` to download necessary providers
4.  `$ terraform apply` to provision nodes and run benchmarks
5.  `$ terraform destroy` to tear down created nodes
