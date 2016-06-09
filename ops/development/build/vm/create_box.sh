#!/bin/bash

set -e

#export PACKER_LOG=1
rm dev-env.box || true
#エラー時はvagrant plugin install vagrant-exec
vagrant exec sudo ln -s -f /dev/null /etc/udev/rules.d/70-persistent-net.rules
vagrant package -o dev-env.box
vagrant box remove dev-env || true
vagrant box add dev-env ./dev-env.box