
module "talos_cluster" {
  source = "../../"

  talos_endpoints = [var.cp_endpoint]
  k8s_endpoint    = "https://${var.cp_endpoint}:6443"

  gateway                = var.gateway
  dns_servers            = var.dns_servers
  proxmox_network_bridge = var.proxmox_network_bridge

  control_plane = [
    {
      vmid         = var.cp_vmid
      node_name    = var.proxmox_node_name
      ipv4_address = var.cp_ip
    }
  ]

  worker = [
    {
      vmid         = var.worker_vmid
      node_name    = var.proxmox_node_name
      ipv4_address = var.worker_ip
    }
  ]
}
