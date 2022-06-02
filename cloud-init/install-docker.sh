#!/usr/bin/env bash

# internet reachable? before continue
until ping4 -c1 google.com &>/dev/null; do sleep 1; done 

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# add ubuntu to docker group
usermod -aG docker ubuntu