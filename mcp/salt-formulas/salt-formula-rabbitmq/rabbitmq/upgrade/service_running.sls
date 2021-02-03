{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_task_service_running:
  test.show_notification:
    - name: "dump_message_service_running_rabbitmq"
    - text: "Running rabbitmq.upgrade.service_running"

{%- if server.get('enabled') %}

rabbitmq_service_running:
  service.running:
  - enable: true
  - name: {{ server.service }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- endif %}
