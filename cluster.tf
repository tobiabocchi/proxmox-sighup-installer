resource "proxmox_vm_qemu" "control-plane" {
  # VM Metadata
  count       = var.k8s_control_plane_count
  name        = "${var.k8s_cluster_name}-control-plane-${count.index}"
  tags        = "cluster_${var.k8s_cluster_name}"
  target_node = var.proxmox_node_name
  vmid        = var.k8s_vm_id + count.index

  # VM Source
  clone = var.proxmox_vm_template

  # Virtual Hardware
  boot    = "order=virtio0"
  cores   = var.k8s_control_plane_cores
  memory  = var.k8s_control_plane_memory
  os_type = "cloud-init"
  scsihw  = "virtio-scsi-pci"

  # Cloud-init customization
  agent     = 1 # Enable QEMU guest agent
  ciupgrade = true
  ciuser    = var.k8s_cluster_name
  ipconfig0 = "ip=${cidrhost("192.168.1.0/24", 40 + count.index)}/24,gw=${cidrhost("192.168.1.0/24", 254)}"
  skip_ipv6 = true
  sshkeys   = local_file.public_key.content

  # Disks, Network and Serial Configuration
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.proxmox_vm_storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = var.k8s_control_plane_disk_size
          storage = var.proxmox_vm_storage
        }
      }
    }
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  serial {
    id = 0
  }
}

resource "proxmox_vm_qemu" "node" {
  # VM Metadata
  count       = var.k8s_node_count
  name        = "${var.k8s_cluster_name}-node-${count.index}"
  tags        = "cluster_${var.k8s_cluster_name}"
  target_node = var.proxmox_node_name
  vmid        = var.k8s_vm_id + 50 + count.index

  # VM Source
  clone = var.proxmox_vm_template

  # Virtual Hardware
  boot    = "order=virtio0"
  cores   = var.k8s_node_cores
  memory  = var.k8s_node_memory
  os_type = "cloud-init"
  scsihw  = "virtio-scsi-pci"

  # Cloud-init customization
  agent     = 1 # Enable QEMU guest agent
  ciupgrade = true
  ciuser    = var.k8s_cluster_name
  ipconfig0 = "ip=${cidrhost("192.168.1.0/24", 45 + count.index)}/24,gw=${cidrhost("192.168.1.0/24", 254)}"
  skip_ipv6 = true
  sshkeys   = local_file.public_key.content

  # Disks, Network and Serial Configuration
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.proxmox_vm_storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = var.k8s_node_disk_size
          storage = var.proxmox_vm_storage
        }
      }
    }
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  serial {
    id = 0
  }
}
