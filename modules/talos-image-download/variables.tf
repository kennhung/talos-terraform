variable "talos_version" {
  type        = string
  description = "The version of Talos to use for the image. Default is the latest stable version."
  default     = ""
}

variable "image_architecture" {
  type        = string
  description = "The architecture for the Talos image. Default is 'amd64'."
  default     = "amd64"
}

variable "image_platform" {
  type        = string
  description = "The platform for the Talos image. Default is 'nocloud'."
  default     = "nocloud"
}


variable "image_extensions" {
  type        = list(string)
  description = "A list of extensions to include in the Talos image."
  default     = ["qemu-guest-agent"]
}

variable "proxmox_node_name" {
  type        = string
  description = "The name of the Proxmox node where the Talos image will be created."
}

variable "proxmox_datastore_id" {
  type        = string
  description = "The ID of the Proxmox datastore where the Talos image will be stored. Default is 'local'."
  default     = "local"
}

variable "image_filename" {
  type        = string
  description = "The filename for the Talos image. If not provided, it will be generated based on the Talos version and schematic ID."
  default     = ""
}

variable "image_filename_prefix" {
  type        = string
  description = "The prefix for the Talos image filename. Will be used to generate the final filename if `image_filename` is not provided."
  default     = ""
}
