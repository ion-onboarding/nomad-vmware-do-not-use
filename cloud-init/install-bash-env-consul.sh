#!/usr/bin/env bash

# find local IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# system wide environment variables - https://help.ubuntu.com/community/EnvironmentVariables#A.2Fetc.2Fprofile.d.2F.2A.sh
tee /etc/profile.d/bash-hashicorp-env-consul.sh > /dev/null <<EOF
export CONSUL_HTTP_ADDR=http://$PRIVATE_IP:8500

# autocomplete
complete -C /usr/bin/consul consul
EOF