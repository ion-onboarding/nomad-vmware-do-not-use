#!/usr/bin/env bash

# nomad installed before configuration
while [ ! -f /usr/bin/nomad ]; do sleep 1; done

# empty default config
echo "" | tee /etc/nomad.d/nomad.hcl

# find local IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# nomad client
tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
# nomad server config
name = "$PRIVATE_IP"
region = "${nomad_region}"
datacenter = "${nomad_datacenter}"
data_dir = "/opt/nomad"

bind_addr = "{{ GetInterfaceIP \"ens192\" }}"

client {
  enabled = true

  server_join {
    retry_join = [ "provider=vsphere category_name=${nomad_category_name} tag_name=${nomad_tag_name} host=${vsphere_server} user=${vsphere_username} password=${vsphere_password} insecure_ssl=true" ]
    retry_max = 5
    retry_interval = "15s"
  }
  
  options = {
    "driver.raw_exec" = "1"
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "127.0.0.1:8500"
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}

enable_debug = true   # to be able to extract logs with nomad operator debug
EOF

# start nomad
systemctl enable nomad
systemctl start nomad