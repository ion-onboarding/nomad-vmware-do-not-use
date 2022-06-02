#
# Nomad
#

variable "nomad_vm_num_cpus" {
  description = "CPU number"
  type        = number
  default     = 1
}

variable "nomad_vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 1024
}

variable "nomad_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "nomad_version" {
  description = "version to be used in format x.y.z, default is null string (meaning latest version)"
  default     = ""
}

variable "nomad_instances_count" {
  description = "How many servers must come online"
  default     = 1
}

variable "nomad_region" {
  description = "Nomad Region name"
  default     = "global"
}

variable "nomad_datacenter" {
  description = "Nomad datacenter name"
  default     = "dc1"
}


#
# Consul
#
variable "consul_vm_num_cpus" {
  description = "CPU number"
  type        = number
  default     = 1
}

variable "consul_vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 1024
}

variable "consul_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "consul_version" {
  description = "version to be used in format x.y.z, default is null string (means latest version)"
  default     = ""
}

variable "consul_instances_count" {
  description = "How many servers must come online. At this moment count cannot be changed"
  default     = 1
}

variable "consul_datacenter" {
  description = "Consul datacenter name"
  default     = "dc1"
}


#
# Vault
#
variable "vault_vm_num_cpus" {
  description = "CPU number"
  type        = number
  default     = 1
}

variable "vault_vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 1024
}

variable "vault_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "vault_version" {
  description = "version to be used in format x.y.z, default is null string (means latest version)"
  default     = ""
}

# at this moment code doesn't support many instances due to unseal automation
variable "vault_instances_count" {
  description = "How many servers must come online"
  default     = 1
}


#
# Client
#
variable "client_vm_num_cpus" {
  description = "CPU number"
  type        = number
  default     = 2
}

variable "client_vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "client_instances_count" {
  description = "How many servers must come online"
  default     = 1
}