
locals {
  talos_pve_nodes = toset(concat([for v in var.control_plane : v.node_name], [for v in var.worker : v.node_name]))
}

module "talos_nocloud_image" {
  source = "./modules/talos-image-download"

  for_each = local.talos_pve_nodes

  proxmox_node_name = each.key

  talos_version = var.talos_version

  image_filename_prefix = var.cluster_name # FIXME: auto generate unique filename_prefix
}

resource "talos_machine_secrets" "machine_secrets" {}
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = var.talos_endpoints
}

data "talos_machine_configuration" "machineconfig_cp" {
  talos_version = module.talos_nocloud_image[tolist(local.talos_pve_nodes)[0]].image_version

  cluster_name     = var.cluster_name
  cluster_endpoint = var.k8s_endpoint

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  # TODO: Implement config_patches
}

data "talos_machine_configuration" "machineconfig_worker" {
  talos_version = module.talos_nocloud_image[tolist(local.talos_pve_nodes)[0]].image_version

  cluster_name     = var.cluster_name
  cluster_endpoint = var.k8s_endpoint

  machine_type    = "worker"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  # TODO: Implement config_patches
}

# IP addresses of cp and workers
locals {
  talos_cp_nodes     = [for cp in var.control_plane : split("/", cp.ipv4_address)[0]]
  talos_worker_nodes = [for worker in var.worker : split("/", worker.ipv4_address)[0]]
}

module "talos_cp_vm" {
  source = "./modules/talos-vm"

  depends_on = [
    talos_machine_secrets.machine_secrets,
    module.talos_nocloud_image,
    data.talos_machine_configuration.machineconfig_cp,
  ]

  for_each = { for idx, cp in var.control_plane : idx => cp }

  vmid      = each.value.vmid
  name      = each.value.name != null ? each.value.name : format("%s-cp%02d", var.cluster_name, each.key + 1)
  node_name = each.value.node_name

  cpu_cores = each.value.cpu_cores
  memory_mb = each.value.memory_mb

  network_bridge = var.proxmox_network_bridge
  ipv4_address   = each.value.ipv4_address
  gateway        = var.gateway

  dns_servers = var.dns_servers

  talos_image_id = module.talos_nocloud_image[each.value.node_name].downloaded_image_file.id

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
}

module "talos_worker_vm" {
  source = "./modules/talos-vm"

  depends_on = [
    talos_machine_secrets.machine_secrets,
    module.talos_nocloud_image,
    data.talos_machine_configuration.machineconfig_worker,
  ]

  for_each = { for idx, worker in var.worker : idx => worker }

  vmid      = each.value.vmid
  name      = each.value.name != null ? each.value.name : format("%s-worker%02d", var.cluster_name, each.key + 1)
  node_name = each.value.node_name

  cpu_cores = each.value.cpu_cores
  memory_mb = each.value.memory_mb

  network_bridge = var.proxmox_network_bridge
  ipv4_address   = each.value.ipv4_address
  gateway        = var.gateway

  dns_servers = var.dns_servers

  talos_image_id = module.talos_nocloud_image[each.value.node_name].downloaded_image_file.id

  additional_disks = [
    {
      size = each.value.additional_disk_size
    }
  ]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [module.talos_cp_vm[0]]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_cp_nodes[0]
}

data "talos_cluster_health" "health" {
  depends_on = [
    module.talos_cp_vm,
    module.talos_worker_vm,
    talos_machine_bootstrap.bootstrap,
  ]

  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = local.talos_cp_nodes
  worker_nodes         = local.talos_worker_nodes
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_cp_nodes[0]
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = resource.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
