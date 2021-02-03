{%- from "rabbitmq/map.jinja" import service with context %}

rabbitmq_upgrade:
  test.show_notification:
    - name: "dump_message_upgrade_rabbitmq"
    - text: "Running rabbitmq.upgrade.upgrade"

include:
 - rabbitmq.upgrade.service_stopped
 - rabbitmq.upgrade.pkgs_latest
 - rabbitmq.upgrade.render_config
 - rabbitmq.upgrade.service_running
