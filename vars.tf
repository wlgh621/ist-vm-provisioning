variable "vsphere_server" {
  type = string
  description = "Hostname or IP address of your vCenter server" 
  default = "10.70.137.15"
}
variable "vsphere_user" {
  type = string
  description = "Username for vsphere"
  default = "Administrator@VSPHERE.LOCAL"
}
variable "vsphere_password" {
  type = string
  description = "The password for vsphere"
  default = "!234Qwer"
}
variable "datacenter" {
  type = string
  description = "The datacenter the resources will be created in"
  default = "DC2"
}
variable "resource_pool" {
  type = string
  description = "Name of the resource pool"
  default = "cisg-arch-day"
}
variable "datastore_name" {
  type = string
  description = "Name of the Datastore name"
  default = "NAS"
}
// The name of the network to use.
variable "network_name" {
  type = string
  description = "Name of the network"
  default = "MGMT-Net_137.x"
}
// The name of the template to use when cloning.
variable "template_name" {
  type = string
  description = "Name of the template"
  default = "ubuntumin"
}
// The virtual machine cpu
variable "vm_cpu" {
  type = number
  description = "Number of vCPUs"
  default = 2
}
variable "vm_memory" {
  type = number
  description = "Amount of memory in MB"
  default = 2048
}
variable "vm_prefix" {
  type = string
  description = "The name prefix of the virtual machines to create"
  default = "jaheo"
}

variable "vm_folder" {
  type = string
  description = "Name of folder"
  default = "cisg-arch-day"
}
variable "vm_count" {
  type = number
  description = "Number of VMs to provision"
  default = 1
}
variable "vm_domain" {
  type = string
  description = "Domain Name for the virtual machine"
  default = "cisg-arch-day"
}
