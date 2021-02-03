{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_task_uprade_verify_service:
  test.show_notification:
    - text: "Running rabbitmq.upgrade.verify.service"

{%- if server.get('enabled') %}
{% set host_id = salt['network.get_hostname']() %}

rabbitmq_status:
  cmd.run:
    - name: rabbitmqctl cluster_status |grep -w running_nodes |grep -w {{ host_id }}
  {%- if grains.get('noservices') %}
    - onlyif: /bin/false
  {%- endif %}

{% endif %}
