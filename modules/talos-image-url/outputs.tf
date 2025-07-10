output "image_version" {
  value = data.talos_image_factory_urls.this.talos_version
}

output "image_schematic_id" {
  value = data.talos_image_factory_urls.this.schematic_id
}

output "image_architecture" {
  value = data.talos_image_factory_urls.this.architecture
}

output "image_platform" {
  value = data.talos_image_factory_urls.this.platform
}

output "image_download_urls" {
  value = data.talos_image_factory_urls.this.urls
}
