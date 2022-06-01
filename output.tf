# password set for ubuntu user through cloud-init/userdata.yml is: ubuntu
locals {
  private_key = fileexists("~/.ssh/id_ed25519") ? "~/.ssh/id_ed25519" : "~/.ssh/id_rsa"
  SSH_nomad   = [for nomad in vsphere_virtual_machine.nomad : " ssh -i ${local.private_key} -o StrictHostKeyChecking=no ubuntu@${nomad.default_ip_address} "]
  SSH_consul  = [for consul in vsphere_virtual_machine.consul : " ssh -i ${local.private_key} -o StrictHostKeyChecking=no ubuntu@${consul.default_ip_address} "]
  SSH_vault   = [for vault in vsphere_virtual_machine.vault : " ssh -i ${local.private_key} -o StrictHostKeyChecking=no ubuntu@${vault.default_ip_address} "]
  SSH_client  = [for client in vsphere_virtual_machine.client : " ssh -i ${local.private_key} -o StrictHostKeyChecking=no ubuntu@${client.default_ip_address} "]

  NOMAD_ADDR       = " export NOMAD_ADDR='http://${vsphere_virtual_machine.nomad[0].default_ip_address}:4646' "
  CONSUL_HTTP_ADDR = " export CONSUL_HTTP_ADDR='http://${vsphere_virtual_machine.consul[0].default_ip_address}:8500' "
  VAULT_ADDR       = " export VAULT_ADDR='http://${vsphere_virtual_machine.vault[0].default_ip_address}:8200' "
  API_http         = [local.NOMAD_ADDR, local.CONSUL_HTTP_ADDR, local.VAULT_ADDR]

  VAULT_login = ["vault login -method=userpass username=admin password=admin"]

}
output "SSH_nomad" {
  value = local.SSH_nomad
}

output "SSH_consul" {
  value = local.SSH_consul
}

output "SSH_vault" {
  value = local.SSH_vault
}

output "SSH_client" {
  value = local.SSH_client
}

output "USER_credentials" {
  value = local.VAULT_login
}

output "API_http" {
  value = local.API_http
}