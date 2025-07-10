terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.40.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8.1"
    }
  }
}
