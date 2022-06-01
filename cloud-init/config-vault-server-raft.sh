#!/usr/bin/env bash

# installed before configuration
while [ ! -f /usr/bin/vault ]; do sleep 1; done

# license
tee /etc/vault.d/vault.hclic > /dev/null <<EOF
${vault_license}
EOF

# empty default config
echo "" | tee /etc/vault.d/vault.hcl

export PRIVATE_IP=$(hostname -I | awk '{print $1}')  
PRIVATE_IP_DASH=$(echo $PRIVATE_IP | sed "s/\./-/g")                  # sed "s/[original]/[target]/g", "s" means "substitute", "g" means "global, all matching occurrences"

# directory integrated storage
mkdir -p /opt/vault/
chown vault:vault /opt/vault/

# configuration file
tee /etc/vault.d/vault.hcl > /dev/null <<EOF
# vault server config
ui            = true
disable_mlock = true

# if OSS binary is used then the license configuration is ignored
license_path = "/etc/vault.d/vault.hclic"

cluster_addr = "http://{{ GetInterfaceIP \"ens192\" }}:8201"
api_addr     = "http://{{ GetInterfaceIP \"ens192\" }}:8200"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-$PRIVATE_IP_DASH"

  retry_join {
    auto_join         = "provider=vsphere category_name=${vault_category_name} tag_name=${vault_tag_name} host=${vsphere_server} user=${vsphere_username} password=${vsphere_password} insecure_ssl=true"
    auto_join_scheme  = "http"
  }
}
EOF

# vault is a service
systemctl enable vault
systemctl start vault

export VAULT_ADDR=http://$PRIVATE_IP:8200
# while vault status ; ret=$? ; [ $ret -ne 2 ];do sleep 1; done

# https://www.vaultproject.io/docs/commands/operator/init
vault operator init -key-shares=1 -key-threshold=1 > /etc/vault.d/unseal.txt

export VAULT_UNSEAL_KEY=$(cat /etc/vault.d/unseal.txt | grep 'Unseal Key 1' | cut -d' ' -f4)

tee /etc/vault.d/payload.json <<EOF
{
  "key": "$VAULT_UNSEAL_KEY"
}
EOF

# unseal
# https://www.vaultproject.io/api-docs/system/unseal
curl --request POST -H "Content-Type: application/json" --data @/etc/vault.d/payload.json  http://$PRIVATE_IP:8200/v1/sys/unseal

# extract root token
export VAULT_TOKEN=$(cat /etc/vault.d/unseal.txt | grep -i token | cut -d' ' -f4)

# wait till vault status returns 0 (unsealed), https://www.vaultproject.io/docs/commands/status
while vault status ; ret=$? ; [ $ret -ne 0 ];do sleep 1; done

# query health endpoint: 200 - if initialized, unsealed, and active
IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2)

# continue if HTTP status is 200
while [[ $IS_200 -ne 200 ]] ; do sleep 1; IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2) ; done

# create a policy with any path allowing all capabilities (root)
tee root-policy.hcl <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

# attach admin policy to admin
vault policy write admin-root root-policy.hcl

# enable username/pasword authentication
vault auth enable userpass
vault write auth/userpass/users/admin password=admin policies=admin-root