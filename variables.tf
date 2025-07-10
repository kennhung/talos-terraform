variable "cluster_name" {
  type    = string
  default = "talos-cluster"
}

variable "talos_version" {
  type    = string
  default = ""
}

variable "talos_endpoints" {
  type = list(string)
}

variable "k8s_endpoint" {
  type = string
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "proxmox_network_bridge" {
  type = string
}

variable "control_plane" {
  type = list(object({
    vmid         = number
    name         = optional(string, null)
    node_name    = string
    cpu_cores    = optional(number, 2)
    memory_mb    = optional(number, 2048)
    ipv4_address = string
  }))

  default = []
}

variable "worker" {
  type = list(object({
    vmid                 = number
    name                 = optional(string, null)
    node_name            = string
    cpu_cores            = optional(number, 4)
    memory_mb            = optional(number, 4096)
    ipv4_address         = string
    additional_disk_size = optional(number, 60)
  }))

  default = []
}
