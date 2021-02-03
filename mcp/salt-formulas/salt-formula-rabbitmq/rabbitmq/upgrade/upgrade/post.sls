{%- from "rabbitmq/map.jinja" import service with context %}

rabbitmq_upgrade_post:
  test.show_notification:
    - name: "dump_message_upgrade_rabbitmq_post"
    - text: "Running rabbitmq.upgrade.upgrade.post"
