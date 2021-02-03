{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_render_config:
  test.show_notification:
    - name: "dump_message_render_config_rabbitmq"
    - text: "Running rabbitmq.upgrade.render_config"

{%- if server.get('enabled', false) %}

rabbitmq_config:
  file.managed:
  - name: {{ server.config_file }}
  - source: salt://rabbitmq/files/rabbitmq.config
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - makedirs: True
  - mode: 440

{%- endif %}
