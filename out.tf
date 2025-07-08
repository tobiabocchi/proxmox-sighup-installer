resource "terraform_data" "create_out_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/out"
  }
}

resource "terraform_data" "create_k8s_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/k8s"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  depends_on           = [terraform_data.create_out_dir]
  content              = tls_private_key.ssh_key.private_key_pem
  filename             = "${path.module}/out/id_rsa"
  file_permission      = 0600
  directory_permission = 0755
}

resource "local_file" "public_key" {
  depends_on           = [terraform_data.create_out_dir, tls_private_key.ssh_key]
  content              = tls_private_key.ssh_key.public_key_openssh
  filename             = "${path.module}/out/id_rsa.pub"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "cluster_hosts_yaml" {
  depends_on = [terraform_data.create_out_dir]
  content = templatefile("${path.module}/templates/hosts.yaml.tftpl", {
    control_planes = [
      for vm in proxmox_vm_qemu.control-plane : {
        hostname = vm.name
        ip       = vm.default_ipv4_address
        # index    = vm.count.index
      }
    ],
    nodes = [
      for vm in proxmox_vm_qemu.node : {
        hostname = vm.name
        ip       = vm.default_ipv4_address
        # index = vm.count.index
      }
    ],
    keypath = local_file.private_key.filename,
    user    = var.k8s_cluster_name,
  })
  filename             = "${path.module}/ansible/hosts.yaml"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "cluster_etc_hosts" {
  depends_on = [terraform_data.create_out_dir]
  content = templatefile("${path.module}/templates/etc_hosts.tftpl", {
    hosts = [
      for vm in concat(proxmox_vm_qemu.control-plane, proxmox_vm_qemu.node) : {
        hostname = "${vm.name}.${var.k8s_cluster_dns_zone}"
        ip       = vm.default_ipv4_address
      }
    ]
  })
  filename             = "${path.module}/ansible/hosts"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "furyctl_yaml" {
  depends_on = [terraform_data.create_k8s_dir]
  content = templatefile("${path.module}/templates/furyctl.yaml.tftpl", {
    control_planes = [
      for vm in proxmox_vm_qemu.control-plane : {
        hostname = vm.name
        ip       = vm.default_ipv4_address
      }
    ],
    nodes = [
      for vm in proxmox_vm_qemu.node : {
        hostname = vm.name
        ip       = vm.default_ipv4_address
      }
    ],
    keypath         = local_file.private_key.filename,
    cluster_name    = var.k8s_cluster_name,
    cluster_version = var.k8s_cluster_version,
    dns_zone        = var.k8s_cluster_dns_zone,
  })
  filename             = "${path.module}/k8s/furyctl.yaml"
  file_permission      = 0644
  directory_permission = 0755
}
