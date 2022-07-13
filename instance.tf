locals {
  vm = csvdecode(file("topgun-vm-csv.csv"))
}

data "vsphere_datacenter" "dc" {
  count = length(local.vm)
  name = local.vm[count.index].datacenter
  #name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  count = length(local.vm)
  name = local.vm[count.index].datastore_name
  #name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc[count.index].id
}

data "vsphere_resource_pool" "pool" {
  count = length(local.vm)
  name = local.vm[count.index].resource_pool
  #name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc[count.index].id
}

data "vsphere_network" "network" {
  count = length(local.vm)
  name = local.vm[count.index].network_name
  #name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc[count.index].id
}

data "vsphere_virtual_machine" "template" {
  count = length(local.vm)
  name = local.vm[count.index].template_name
  #name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc[count.index].id
}

resource "random_string" "folder_name_prefix" {
  length    = 5
  min_lower = 5
  special   = false
  lower     = true

}


resource "vsphere_folder" "vm_folder" {
  count = length(local.vm)
  path          =  "${local.vm[count.index].vm_folder}-${random_string.folder_name_prefix.id}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc[count.index].id
}

#Lets see something cool with Cisco Intersight & TFCB
resource "vsphere_virtual_machine" "vm_deploy" {
  for_each = { for vm in local.vm : vm.ip => vm }
  name = each.value.vm_prefix
  resource_pool_id = data.vsphere_resource_pool.pool[each.value.index].id
  #resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore[each.value.index].id
  #datastore_id     = data.vsphere_datastore.datastore.id
  folder           =  vsphere_folder.vm_folder[each.value.index].path
  #folder           = vsphere_folder.vm_folder.path

  num_cpus = each.value.vm_cpu
  memory   = each.value.memory
  guest_id = data.vsphere_virtual_machine.template[each.value.index].guest_id
  #guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template[each.value.index].scsi_type
  #scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network[each.value.index].id
    #network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template[each.value.index].network_interface_types[0]
    #adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size = data.vsphere_virtual_machine.template[each.value.index].disks.0.size
    #size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template[each.value.index].disks.0.eagerly_scrub
    #eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template[each.value.index].disks.0.thin_provisioned
    #thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.value.index].id
    #template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name  = each.value.vm_prefix
        domain    =  each.value.vm_domain
      }
      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = each.value.ipv4_netmask
      }
      ipv4_gateway    =  each.value.ipv4_gateway
      dns_server_list = [each.value.dns_server_list]
      
    }
  }

}

