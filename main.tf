
locals {
  talos_pve_nodes = toset(concat([for v in var.control_plane : v.node_name], [for v in var.worker : v.node_name]))
}

module "talos_nocloud_image" {
  source = "./modules/talos-image-download"

  for_each = local.talos_pve_nodes

  proxmox_node_name = each.key
  
  talos_version     = var.talos_version
}
