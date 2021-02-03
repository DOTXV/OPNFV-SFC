{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_post:
  test.show_notification:
    - name: "dump_message_post-upgrade"
    - text: "Running rabbitmq.upgrade.post"

{%- if server.get('enabled') %}

rabbitmq_status:
  cmd.run:
    - name: rabbitmqctl cluster_status
  {%- if grains.get('noservices') %}
    - onlyif: /bin/false
  {%- endif %}

{%- endif %}
