# --- Proxmox Server ---
variable "proxmox_host_ip" {
  type        = string
  default     = "192.168.1.3"
  description = "Proxmox host IP address"
}
variable "proxmox_token_id" {
  type        = string
  default     = "terraform-prov@pve!mytoken"
  description = "Proxmox API token ID"
}
variable "proxmox_token_secret" {
  type        = string
  default     = ""
  description = "Proxmox API token secret"
}
variable "proxmox_node_name" {
  type        = string
  default     = "pve"
  description = "Proxmox node name"
}
variable "proxmox_vm_storage" {
  type        = string
  default     = "fast-storage"
  description = "Proxmox VM storage"
}
variable "proxmox_vm_template" {
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
  description = "Proxmox VM template"
}

# --- Kubernetes Cluster ---
variable "k8s_cluster_name" {
  type        = string
  default     = "demo"
  description = "Name of the cluster"
}
variable "k8s_cluster_dns_zone" {
  type        = string
  default     = "example.dev"
  description = "Name of the cluster"
}
variable "k8s_vm_id" {
  type        = number
  default     = 100
  description = "Base ID for VMs in the cluster"
}
variable "k8s_control_plane_count" {
  type        = number
  default     = 1
  description = "Number of control plane nodes"
}
variable "k8s_control_plane_memory" {
  type        = number
  default     = 8192
  description = "Control plane node memory in MB"
}
variable "k8s_control_plane_cores" {
  type        = number
  default     = 2
  description = "Control plane node CPU cores"
}
variable "k8s_control_plane_disk_size" {
  type        = number
  default     = 30
  description = "Control plane disk size in GB"
}
variable "k8s_node_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}
variable "k8s_node_memory" {
  type        = number
  default     = 4096
  description = "Control plane node memory in MB"
}
variable "k8s_node_cores" {
  type        = number
  default     = 4
  description = "Control plane node CPU cores"
}
variable "k8s_node_disk_size" {
  type        = number
  default     = 50
  description = "Node disk size in GB"
}

# --- Misc ---
variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH public key"
}
