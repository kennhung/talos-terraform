variable "vmid" {
  type        = number
  description = "VM ID for the Talos VM."
}

variable "node_name" {
  type        = string
  description = "Proxmox node name where the Talos VM will be created."
}

variable "name" {
  type        = string
  description = "Name of the Talos VM."
}

variable "description" {
  type        = string
  description = "Description of the Talos VM."
  default     = "Managed by Terraform"
}

variable "cpu_cores" {
  type        = number
  description = "Number of CPU cores for the Talos VM."
}

variable "cpu_type" {
  type        = string
  description = "CPU type for the Talos VM."
  default     = "kvm64"
}

variable "memory_mb" {
  type        = number
  description = "Memory size (MB) for the Talos VM."
}

variable "network_bridge" {
  type        = string
  description = "Network bridge for the Talos VM."
}

variable "ipv4_address" {
  type        = string
  description = "IPv4 address for the Talos VM."
}

variable "gateway" {
  type        = string
  description = "Gateway for the Talos VM."
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers for the Talos VM. Defaults use the node's config."
  default     = []
}

variable "datastore_id" {
  type        = string
  description = "Datastore ID for the Talos VM. Defaults to 'local-lvm'."
  default     = "local-lvm"
}
variable "talos_image_id" {
  type        = string
  description = "Talos image ID for the VM."
}

variable "talos_disk_size" {
  type        = number
  description = "Size of the Talos disk in GB. Defaults to 20GB."
  default     = 20
}

variable "additional_disks" {
  description = "A list of additional disk configurations for the VM."
  type = list(object({
    datastore_id = optional(string, "local-lvm")
    size         = number
  }))
  default = []
}

variable "client_configuration" {
  description = "Client configuration for the Talos VM."
}

variable "machine_configuration_input" {
  type        = string
  description = "Machine configuration input for the Talos VM."
}
