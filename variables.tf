variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster."
  default     = "talos-cluster"
}

variable "talos_version" {
  type        = string
  description = "Talos version to use (empty for latest)."
  default     = ""
}

variable "talos_image_ids" {
  type        = map(string)
  description = "Talos image ID to use (only for custom image; if not supplied, the module will automatically download the image)."
  default     = null
}

variable "talos_endpoints" {
  type        = list(string)
  description = "List of Talos endpoint IP addresses."
}

variable "k8s_endpoint" {
  type        = string
  description = "Kubernetes API endpoint IP address."
}

variable "gateway" {
  type        = string
  description = "Network gateway IP address."
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS server IP addresses."
}

variable "proxmox_network_bridge" {
  type        = string
  description = "Proxmox network bridge to use for the VMs."
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
  description = "Control plane node configurations."

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
  description = "Worker node configurations."

  default = []
}
