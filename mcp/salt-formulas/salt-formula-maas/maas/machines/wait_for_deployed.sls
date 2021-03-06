{%- from "maas/map.jinja" import region with context %}

maas_login_admin:
  cmd.run:
  - name: "maas-region apikey --username {{ region.admin.username }} > /var/lib/maas/.maas_credentials"

wait_for_machines_deployed:
  module.run:
  - name: maas.wait_for_machine_status
  - kwargs:
        req_status: "Deployed"
        timeout: {{ region.timeout.deployed }}
        attempts: {{ region.timeout.attempts }}
  - require:
    - cmd: maas_login_admin
