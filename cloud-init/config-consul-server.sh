#!/usr/bin/env bash

# consul installed before configuration
while [ ! -f /usr/bin/consul ]; do sleep 1; done

# license
tee /etc/consul.d/consul.hclic > /dev/null <<EOF
${consul_license}
EOF

# empty default config
echo "" | tee /etc/consul.d/consul.hcl

# find local IP, transform x.y.z.w => x-y-z-w (to avoid dns issues)
PRIVATE_IP=$(hostname -I | awk '{print $1}' | sed "s/\./-/g")  
PRIVATE_IP_DASH=$(echo $PRIVATE_IP | sed "s/\./-/g")                  # sed "s/[original]/[target]/g", "s" means "substitute", "g" means "global, all matching occurrences"

# consul server
tee /etc/consul.d/consul.hcl > /dev/null <<EOF
# consul server config
node_name  = "consul-$PRIVATE_IP_DASH"
datacenter = "${consul_datacenter}"
data_dir   = "/opt/consul"

bind_addr   = "{{ GetInterfaceIP \"ens192\" }}"
client_addr = "0.0.0.0"

server           = true
license_path     = "/etc/consul.d/consul.hclic"
raft_protocol    = 3
bootstrap_expect = ${consul_bootstrap}

retry_join = [ "provider=vsphere category_name=${consul_category_name} tag_name=${consul_tag_name} host=${vsphere_server} user=${vsphere_username} password=${vsphere_password} insecure_ssl=true" ]
retry_max      = 5
retry_interval = "15s"

# Consul UI
ui_config {
  enabled = true
}

# service mesh
connect {
  enabled = true
}

addresses {
  grpc = "127.0.0.1"
}

ports {
  grpc = 8502
}
EOF

# start consul
systemctl enable consul
systemctl start consul