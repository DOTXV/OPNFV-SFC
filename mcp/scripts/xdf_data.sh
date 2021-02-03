#!/bin/bash -e
# shellcheck disable=SC2034
##############################################################################
# Copyright (c) 2018 Mirantis Inc., Enea AB and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
#
# Data derived from XDF (PDF/IDF/SDF/etc), used as input in deploy.sh
#
# Determine bridge names based on IDF, where all bridges are now mandatory
OPNFV_BRIDGES=(
  'pxebr'
  'mgmt'
  'internal'
  'public'
)

export CLUSTER_DOMAIN=mcp-odl-noha.local
dns_public=8.8.8.8
cluster_states=('virtual_init' 'opendaylight' 'openstack_noha' 'neutron_gateway' 'tacker' 'networks' )
virtual_nodes=('cmp001' 'cmp002' 'ctl01' 'gtw01' 'odl01' )
control_nodes_query='ctl01* or gtw01* or odl01*'
base_image=https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

# Serialize vnode data as:
#   <name0>,<ram0>,<vcpu0>[,<sockets0>,<cores0>,<threads0>[,<cell0name0>,<cell0memory0>,
#   <cell0cpus0>,<cell1name0>,<cell1memory0>,<cell1cpus0>]]|<name1>,...'
virtual_nodes_data='cmp001,100G;100G,8192,4,|cmp002,100G;100G,8192,4,|ctl01,100G,14336,4,|gtw01,100G,2048,2,|odl01,100G,6144,4,'

# Serialize repos, packages to (pre-)install/remove for:
# - foundation node VM base image (virtual: all VMs, baremetal: cfg01|mas01)
# - virtualized control plane VM base image (only when VCP is used)
virtual_repos_pkgs='https://repo.saltstack.com/apt/ubuntu/18.04/amd64/2017.7/SALTSTACK-GPG-KEY.pub^saltstack|500|deb|[arch=amd64]|http://repo.saltstack.com/apt/ubuntu/18.04/amd64/2017.7|bionic|main^linux-image-5.0.0-37-generic,linux-headers-5.0.0-37-generic,salt-minion,ifupdown,cloud-init,dnsmasq^'