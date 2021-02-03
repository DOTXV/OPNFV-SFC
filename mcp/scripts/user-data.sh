#!/bin/bash
##############################################################################
# Copyright (c) 2018 Mirantis Inc., Enea AB and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
rm -f /etc/salt/minion_id /etc/salt/pki/minion/minion_master.pub
echo "id: $(hostname).mcp-odl-noha.local" > /etc/salt/minion
echo "master: 192.168.11.2" >> /etc/salt/minion
ldconfig
systemctl unmask networking.service || true
systemctl enable networking.service || true
systemctl start networking.service || true
systemctl enable salt-minion.service
systemctl restart salt-minion.service