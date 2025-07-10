
variable "proxmox_node_name" {
  description = "Proxmox node name where the VMs will be created"
  type        = string
}

variable "cp_endpoint" {
  description = "Endpoint for the control plane node"
  type        = string
}

variable "cp_vmid" {
  description = "VM ID for the control plane node"
  type        = number
}

variable "cp_ip" {
  description = "IP address of the control plane node (In CIDR notation)"
  type        = string
}

variable "worker_vmid" {
  description = "VM ID for the worker node"
  type        = number
}

variable "worker_ip" {
  description = "IP address of the worker node (In CIDR notation)"
  type        = string
}

variable "gateway" {
  description = "Gateway IP address"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS server IP addresses"
  type        = list(string)
  default     = []
}

variable "proxmox_network_bridge" {
  description = "Proxmox network bridge to use"
  type        = string
}
