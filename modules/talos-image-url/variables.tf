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
