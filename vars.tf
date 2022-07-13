variable "vsphere_server" {
  type = string
  description = "Hostname or IP address of your vCenter server" 
}
variable "vsphere_user" {
  type = string
  description = "Username for vsphere"
}
variable "vsphere_password" {
  type = string
  description = "The password for vsphere"
}
variable "vm_folder" {
  type = string
  default = "IST-Demo"
  description = "Username for vsphere"
}
variable "default_tags" {
  default = ""
}
