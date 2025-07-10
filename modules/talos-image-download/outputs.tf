
output "image_download_url" {
  value = local.download_url
}

output "image_version" {
  value = local.talos_version
}

output "image_schematic_id" {
  value = local.schematic_id
}

output "downloaded_image_file" {
  value = proxmox_virtual_environment_download_file.talos_nocloud_image
}
