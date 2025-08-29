
resource "proxmox_virtual_environment_vm" "vm" {
  vm_id       = var.vmid
  name        = var.name
  description = var.description
  tags        = ["terraform"]
  node_name   = var.node_name
  on_boot     = true

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
    floating  = var.memory_mb
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.network_bridge
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = var.talos_image_id
    file_format  = "raw"
    interface    = "virtio0"
    size         = var.talos_disk_size
  }

  dynamic "disk" {
    for_each = var.additional_disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = "virtio${disk.key + 1}"
      size         = disk.value.size
    }
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = var.datastore_id

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

resource "talos_machine_configuration_apply" "config_apply" {
  depends_on = [proxmox_virtual_environment_vm.vm]

  client_configuration        = var.client_configuration
  machine_configuration_input = var.machine_configuration_input

  node = split("/", var.ipv4_address)[0]
}
