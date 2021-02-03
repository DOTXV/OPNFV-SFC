{%- from "rabbitmq/map.jinja" import server  with context %}

rabbitmq_task_service_stopped:
  test.show_notification:
    - name: "dump_message_service_stopped_rabbitmq"
    - text: "Running rabbitmq.upgrade.service_stopped"

{%- if server.get('enabled') %}

rabbitmq_service_stopped:
  service.dead:
  - enable: false
  - name: {{ server.service }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- endif %}

