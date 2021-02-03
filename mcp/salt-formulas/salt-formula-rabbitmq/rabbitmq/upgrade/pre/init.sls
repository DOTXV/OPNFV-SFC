{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_pre:
  test.show_notification:
    - name: "dump_message_pre-upgrade_rabbitmq"
    - text: "Running rabbitmq.upgrade.pre"

{%- if server.get('enabled') %}

rabbitmq_status:
  cmd.run:
    - name: rabbitmqctl cluster_status
  {%- if grains.get('noservices') %}
    - onlyif: /bin/false
  {%- endif %}

{%- endif %}
