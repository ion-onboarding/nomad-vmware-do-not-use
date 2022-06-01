#!/usr/bin/env bash

# internet reachable? before continue
until ping4 -c1 releases.hashicorp.com ; do sleep 1; done

# update
apt-get update -qq >/dev/null

# install latest version
apt-get install -y -qq ${nomad}
