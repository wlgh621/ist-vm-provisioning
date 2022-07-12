locals {
  vm = csvdecode(file("./csv/topgun-vm-csv.csv"))
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "random_string" "folder_name_prefix" {
  length    = 5
  min_lower = 5
  special   = false
  lower     = true

}


resource "vsphere_folder" "vm_folder" {
  path          =  "${var.vm_folder}-${random_string.folder_name_prefix.id}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Lets see something cool with Cisco Intersight & TFCB
resource "vsphere_virtual_machine" "vm_deploy" {
  for_each = { for inst in local.vm : inst.vm_memory => inst }
  name = each.value.vm_prefix
  #name             = "${local.vm[count.index].vm_prefix}-${random_string.folder_name_prefix.id}-${count.index + 1}"

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.vm_folder.path

  num_cpus = each.value.vm_cpu
  #num_cpus = var.vm_cpu
  memory   = each.value.vm_memory
  #memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.vm_prefix}-${random_string.folder_name_prefix.id}-${count.index + 1}"
        domain    = var.vm_domain
      }
      network_interface {
        ipv4_address = each.value.ip
        #ipv4_address = local.vm[count.index].IP
        #ipv4_address = lookup(var.master_ips, count.index)
        ipv4_netmask = var.ipv4_netmask
      }
      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = [var.dns_server_list]
      
    }
  }

}

