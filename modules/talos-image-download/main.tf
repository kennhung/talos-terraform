
data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  talos_version = var.talos_version != "" ? var.talos_version : element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.talos_version
  filters = {
    names = var.image_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  architecture  = var.image_architecture
  platform      = var.image_platform
}

locals {
  schematic_id = data.talos_image_factory_urls.this.schematic_id
  # Replace the .xz extension with .gz for the download URL
  # This is necessary because the Proxmox download_file resource does not support .xz files directly.
  download_url = replace(data.talos_image_factory_urls.this.urls.disk_image, "/\\.xz$/", ".gz")
}

locals {
  image_filename = var.image_filename != "" ? var.image_filename : "${var.image_filename_prefix}talos-${local.talos_version}-${local.schematic_id}-${var.image_platform}-${var.image_architecture}.img"
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
