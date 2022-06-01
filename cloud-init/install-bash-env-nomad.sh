#!/usr/bin/env bash

# find local IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# system wide environment variables - https://help.ubuntu.com/community/EnvironmentVariables#A.2Fetc.2Fprofile.d.2F.2A.sh
tee /etc/profile.d/bash-hashicorp-env-nomad.sh > /dev/null <<EOF
export NOMAD_ADDR=http://$PRIVATE_IP:4646

# autocomplete
complete -C /usr/bin/nomad nomad
EOF