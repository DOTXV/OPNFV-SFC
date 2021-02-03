rabbitmq_upgrade_verify:
  test.show_notification:
    - name: "dump_message_upgrade_rabbitmq_verify"
    - text: "Running rabbitmq.upgrade.verify"

include:
 - rabbitmq.upgrade.verify._service
