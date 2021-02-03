{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_upgrade_pre:
  test.show_notification:
    - name: "dump_message_upgrade_rabbitmq_pre"
    - text: "Running rabbitmq.upgrade.upgrade.pre"
