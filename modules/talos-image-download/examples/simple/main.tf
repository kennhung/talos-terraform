
provider "proxmox" {}

module "talos_image" {
  source = "../../"

  proxmox_node_name = var.node_name
}

output "image_schematic_id" {
  value = module.talos_image.image_schematic_id
}

output "image_download_url" {
  value = module.talos_image.image_download_url
}

output "downloaded_file" {
  value = module.talos_image.downloaded_image_file
}
