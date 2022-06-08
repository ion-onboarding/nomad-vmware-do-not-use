resource "random_pet" "name" {
  length = 2
}

resource "vsphere_tag_category" "terraform_project" {
  name        = "${var.main_project_tag}-${random_pet.name.id}"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}

resource "vsphere_tag" "terraform_tag" {
  name        = var.main_project_tag
  category_id = vsphere_tag_category.terraform_project.id
  description = "Managed by Terraform"
}

resource "vsphere_folder" "vm" {
  path          = "terraform-vms-${random_pet.name.id}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_ovf_vm_template" "ovfRemote" {
  name              = "foo"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  remote_ovf_url    = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network.id
  }
}

## Deployment of VM from OVA - https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine
resource "vsphere_virtual_machine" "nomad" {
  count = var.nomad_instances_count
  name  = "nomad-${random_pet.name.id}-${count.index}"

  folder = vsphere_folder.vm.path

  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id # host system ID is required for ovf deployment
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id

  num_cpus  = var.nomad_vm_num_cpus
  memory    = var.nomad_vm_memory
  guest_id  = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  scsi_type = data.vsphere_ovf_vm_template.ovfRemote.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }

  cdrom {
    client_device = true # must be added for cloud-init to work
  }

  vapp {
    properties = {
      user-data = base64gzip(local.vm_nomad_cloud_init)
    }
  }

  tags = ["${vsphere_tag.terraform_tag.id}"]
}

resource "vsphere_virtual_machine" "consul" {
  count = var.consul_instances_count
  name  = "consul-${random_pet.name.id}-${count.index}"
  
  folder = vsphere_folder.vm.path

  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id # host system ID is required for ovf deployment
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id

  num_cpus  = var.consul_vm_num_cpus
  memory    = var.consul_vm_memory
  guest_id  = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  scsi_type = data.vsphere_ovf_vm_template.ovfRemote.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }

  cdrom {
    client_device = true # must be added for cloud-init to work
  }

  vapp {
    properties = {
      user-data = base64gzip(local.vm_consul_cloud_init)
    }
  }

  tags = ["${vsphere_tag.terraform_tag.id}"]
}

resource "vsphere_virtual_machine" "vault" {
  count = var.vault_instances_count
  name  = "vault-${random_pet.name.id}-${count.index}"

  folder = vsphere_folder.vm.path
  
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id # host system ID is required for ovf deployment
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id

  num_cpus  = var.vault_vm_num_cpus
  memory    = var.vault_vm_memory
  guest_id  = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  scsi_type = data.vsphere_ovf_vm_template.ovfRemote.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }

  cdrom {
    client_device = true # must be added for cloud-init to work
  }

  vapp {
    properties = {
      user-data = base64gzip(local.vm_vault_cloud_init)
    }
  }

  tags = ["${vsphere_tag.terraform_tag.id}"]
}

resource "vsphere_virtual_machine" "client" {
  count = var.client_instances_count
  name  = "client-${random_pet.name.id}-${count.index}"

  folder = vsphere_folder.vm.path
  
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id # host system ID is required for ovf deployment
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id

  num_cpus  = var.client_vm_num_cpus
  memory    = var.client_vm_memory
  guest_id  = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  scsi_type = data.vsphere_ovf_vm_template.ovfRemote.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }

  cdrom {
    client_device = true # must be added for cloud-init to work
  }

  vapp {
    properties = {
      user-data = base64gzip(local.vm_client_cloud_init)
    }
  }

  tags = ["${vsphere_tag.terraform_tag.id}"]
}
