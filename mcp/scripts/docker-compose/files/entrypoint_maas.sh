#!/bin/bash -e
##############################################################################
# Copyright (c) 2019 Mirantis Inc., Enea AB and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
if [ ! -e /var/lib/postgresql/*/main ]; then
    cp -ar /var/lib/opnfv/{postgresql,maas} /var/lib/
    cp -ar /var/lib/opnfv/etc/maas /etc/
fi
chown -R maas:maas /var/lib/maas /etc/maas
chown -R postgres:postgres /var/lib/postgresql
chown -R proxy:proxy /var/spool/maas-proxy

if [ ! -f /etc/sysctl.d/99-salt.conf ]; then
    echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-salt.conf
fi

cat <<-EOF | tee /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

cat <<-EOF | tee /etc/salt/minion.d/opnfv.conf
id: mas01.mcp-odl-noha.local
master: 10.20.0.2
grains:
  virtual_subtype: Docker_
EOF
rm -f /etc/salt/minion.d/99-master-address.conf

# Work around MaaS issues with PXE/admin using jumbo frames
MAAS_MTU_SERVICE="/etc/systemd/system/maas-mtu.service"
cat <<-EOF | tee "${MAAS_MTU_SERVICE}"
[Unit]
Requires=network-online.target
After=network-online.target
[Service]
ExecStart=/bin/sh -ec '\
  /sbin/ifconfig $(/sbin/ip addr | /bin/grep -Po "192.168.11.3.* \K(.*)") mtu 1500'
EOF
ln -sf "${MAAS_MTU_SERVICE}" "/etc/systemd/system/multi-user.target.wants/"

# Configure mass-region-controller if not already done previously
[ ! -e /var/lib/maas/secret ] || exit 0
MAAS_FIXUP_SERVICE="/etc/systemd/system/maas-fixup.service"
cat <<-EOF | tee "${MAAS_FIXUP_SERVICE}"
[Unit]
After=postgresql.service
[Service]
ExecStart=/bin/sh -ec '\
  echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
  /var/lib/dpkg/info/maas-region-controller.config configure && \
  /var/lib/dpkg/info/maas-region-controller.postinst configure'
EOF
ln -sf "${MAAS_FIXUP_SERVICE}" "/etc/systemd/system/multi-user.target.wants/"
rm "/usr/sbin/policy-rc.d"