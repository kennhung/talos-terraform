
variable "vm_id" {
  type        = number
  description = "VM ID for the Talos VM."
}

variable "node_name" {
  type        = string
  description = "The name of the Proxmox node where the Talos image will be created."
}

variable "network_bridge" {
  type        = string
  description = "The network bridge to which the Talos VM will be connected."
}

variable "ipv4_address" {
  type        = string
  description = "The IPv4 address for the Talos VM."
}

variable "gateway" {
  type        = string
  description = "The gateway for the Talos VM."
}

variable "talos_image_id" {
  type        = string
  description = "The Talos image ID to use for the VM."
}
