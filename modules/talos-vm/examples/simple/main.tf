
provider "proxmox" {}

locals {
  talos_vm_ip = split("/", var.ipv4_address)[0]
}

resource "talos_machine_secrets" "machine_secrets" {}

data "talos_machine_configuration" "machineconfig" {
  cluster_name     = "example-cluster"
  cluster_endpoint = "https://${local.talos_vm_ip}:6443"

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets
}

module "talos_vm" {
  source = "../../"

  vmid      = var.vm_id
  node_name = var.node_name

  name = "example-simple-talos-vm"

  cpu_cores = 2
  memory_mb = 2048

  network_bridge = var.network_bridge
  ipv4_address   = var.ipv4_address
  gateway        = var.gateway

  talos_image_id = var.talos_image_id

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig.machine_configuration
}
