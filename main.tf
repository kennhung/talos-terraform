
locals {
  talos_pve_nodes = toset(concat([for v in var.control_plane : v.node_name], [for v in var.worker : v.node_name]))
}

module "talos_image_url" {
  source = "./modules/talos-image-url"

  talos_version = var.talos_version
}

resource "random_pet" "talos_image_name" {}

locals {
  image_filename = format("%s.img", join("-", [
    "talos",
    module.talos_image_url.image_version,
    module.talos_image_url.image_schematic_id,
    module.talos_image_url.image_platform,
    module.talos_image_url.image_architecture,
    random_pet.talos_image_name.id,
  ]))
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each = var.talos_image_ids == null ? local.talos_pve_nodes : []

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  # Replace the .xz extension with .gz for the download URL
  # This is necessary because the Proxmox download_file resource does not support .xz files directly.
  url                     = replace(module.talos_image_url.image_download_urls.disk_image, "/\\.xz$/", ".gz")
  file_name               = local.image_filename
  decompression_algorithm = "gz"
  overwrite               = false
}

locals {
  talos_nocloud_image_ids = var.talos_image_ids != null ? var.talos_image_ids : {
    for node_name, file in proxmox_virtual_environment_download_file.talos_nocloud_image :
    node_name => file.id
  }
}

resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = var.talos_endpoints
}

data "talos_machine_configuration" "machineconfig_cp" {
  talos_version = module.talos_image_url.image_version

  cluster_name     = var.cluster_name
  cluster_endpoint = var.k8s_endpoint

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  # TODO: Implement config_patches
}

data "talos_machine_configuration" "machineconfig_worker" {
  talos_version = module.talos_image_url.image_version

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

  talos_image_id = local.talos_nocloud_image_ids[each.value.node_name]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
}

module "talos_worker_vm" {
  source = "./modules/talos-vm"

  depends_on = [
    talos_machine_secrets.machine_secrets,
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

  talos_image_id = local.talos_nocloud_image_ids[each.value.node_name]

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
