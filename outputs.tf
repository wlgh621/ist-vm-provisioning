
output "vm_deploy" {
  value = [vsphere_virtual_machine.vm_deploy.*.name, vsphere_virtual_machine.vm_deploy.*.default_ip_address]
}
output "vm_ip" {
  value = vsphere_virtual_machine.vm_deploy.*.default_ip_address
}
output "vm_name" {
  value = vsphere_virtual_machine.vm_deploy.*.name
}
