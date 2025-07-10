# Talos Terraform Module

A Terraform module for deploying Talos Linux clusters on Proxmox Virtual Environment (PVE). This module automates the creation of Talos VMs, cluster bootstrapping, and provides both Talos and Kubernetes configuration outputs.

## Features

- **Automated Talos Image Management**: Downloads and manages Talos images with custom extensions
- **Flexible VM Configuration**: Supports both control plane and worker nodes with customizable resources
- **Multi-Node Support**: Deploy across multiple Proxmox nodes
- **Cluster Bootstrapping**: Automatic Talos cluster initialization
- **Health Monitoring**: Built-in cluster health checks
- **Configuration Outputs**: Provides both `talosconfig` and `kubeconfig` for cluster access

## Usage

### Basic Example

```hcl
module "talos_cluster" {
  source = "path/to/this/module"

  cluster_name = "my-talos-cluster"
  
  talos_endpoints = ["192.168.1.10"]
  k8s_endpoint    = "https://192.168.1.10:6443"
  
  gateway                = "192.168.1.1"
  dns_servers            = ["8.8.8.8", "8.8.4.4"]
  proxmox_network_bridge = "vmbr0"

  control_plane = [
    {
      vmid         = 100
      node_name    = "pve-node1"
      ipv4_address = "192.168.1.10/24"
      cpu_cores    = 4
      memory_mb    = 4096
    }
  ]

  worker = [
    {
      vmid         = 101
      node_name    = "pve-node1"
      ipv4_address = "192.168.1.11/24"
      cpu_cores    = 4
      memory_mb    = 8192
      additional_disk_size = 100
    }
  ]
}
```

### Multi-Node Cluster Example

```hcl
module "talos_cluster" {
  source = "path/to/this/module"

  cluster_name = "production-cluster"
  
  talos_endpoints = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
  k8s_endpoint    = "https://192.168.1.10:6443"
  
  gateway                = "192.168.1.1"
  dns_servers            = ["192.168.1.1"]
  proxmox_network_bridge = "vmbr0"

  control_plane = [
    {
      vmid         = 100
      node_name    = "pve-node1"
      ipv4_address = "192.168.1.10/24"
    },
    {
      vmid         = 101
      node_name    = "pve-node2"
      ipv4_address = "192.168.1.11/24"
    },
    {
      vmid         = 102
      node_name    = "pve-node3"
      ipv4_address = "192.168.1.12/24"
    }
  ]

  worker = [
    {
      vmid         = 110
      node_name    = "pve-node1"
      ipv4_address = "192.168.1.20/24"
      cpu_cores    = 8
      memory_mb    = 16384
    },
    {
      vmid         = 111
      node_name    = "pve-node2"
      ipv4_address = "192.168.1.21/24"
      cpu_cores    = 8
      memory_mb    = 16384
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | Name of the Talos cluster | `string` | `"talos-cluster"` | no |
| `talos_version` | Talos version to use (empty for latest) | `string` | `""` | no |
| `talos_image_ids` | Talos image ID to use (only for custom image; if not supplied, the module will automatically download the image) | `map(string)` | `null` | no |
| `talos_endpoints` | List of Talos endpoint IP addresses | `list(string)` | n/a | yes |
| `k8s_endpoint` | Kubernetes API endpoint URL | `string` | n/a | yes |
| `gateway` | Network gateway IP address | `string` | n/a | yes |
| `dns_servers` | List of DNS server IP addresses | `list(string)` | n/a | yes |
| `proxmox_network_bridge` | Proxmox network bridge name | `string` | n/a | yes |
| `control_plane` | Control plane node configurations | `list(object)` | `[]` | no |
| `worker` | Worker node configurations | `list(object)` | `[]` | no |

### Control Plane Node Configuration

```hcl
control_plane = [
  {
    vmid         = number           # Proxmox VM ID
    name         = string           # Optional: VM name (auto-generated if not provided)
    node_name    = string           # Proxmox node name
    cpu_cores    = number           # Optional: CPU cores (default: 2)
    memory_mb    = number           # Optional: Memory in MB (default: 2048)
    ipv4_address = string           # IP address in CIDR notation
  }
]
```

### Worker Node Configuration

```hcl
worker = [
  {
    vmid                 = number   # Proxmox VM ID
    name                 = string   # Optional: VM name (auto-generated if not provided)
    node_name            = string   # Proxmox node name
    cpu_cores            = number   # Optional: CPU cores (default: 4)
    memory_mb            = number   # Optional: Memory in MB (default: 4096)
    ipv4_address         = string   # IP address in CIDR notation
    additional_disk_size = number   # Optional: Additional disk size in GB (default: 60)
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| `talosconfig` | Talos client configuration (sensitive) |
| `kubeconfig` | Kubernetes configuration (sensitive) |

## Modules

This project includes several sub-modules:

### talos-image-url

Located in [`modules/talos-image-url/`](modules/talos-image-url/), this module generates Talos image URLs with custom extensions.

### talos-vm

Located in [`modules/talos-vm/`](modules/talos-vm/), this module creates and configures individual Talos VMs on Proxmox.

## File Structure

```
.
├── main.tf                     # Main module configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── versions.tf                 # Provider requirements
├── modules/
│   ├── talos-image-url/        # Talos image URL generation module
│   └── talos-vm/               # Talos VM creation module
└── examples/
    └── simple/                 # Simple usage example
```

## Development

### Testing

The project includes example configurations that can be used for testing:

```bash
# Test the main module
cd examples/simple
terraform init
terraform plan

# Test individual modules
cd modules/talos-vm/examples/simple
terraform init
terraform plan
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the provided examples
5. Submit a pull request
