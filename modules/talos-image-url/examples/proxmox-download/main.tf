
provider "proxmox" {}

module "talos_image_url" {
  source = "../../"
}

locals {
  # Replace the .xz extension with .gz for the download URL
  # This is necessary because the Proxmox download_file resource does not support .xz files directly.
  download_url = replace(module.talos_image_url.image_download_urls.disk_image, "/\\.xz$/", ".gz")

  image_filename = "talos-${module.talos_image_url.image_version}-${module.talos_image_url.image_schematic_id}-nocloud-amd64.img"
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = var.proxmox_datastore_id
  node_name    = var.proxmox_node_name

  file_name               = local.image_filename
  url                     = local.download_url
  decompression_algorithm = "gz"
  overwrite               = false
}
