
panko_upgrade_verify_api:
  test.show_notification:
    - text: "Running panko.upgrade.verify.api"

pankov2_event_list:
  module.run:
    - name: pankov2.event_list
    - kwargs:
        cloud_name: admin_identity

pankov2_event_type_list:
  module.run:
    - name: pankov2.event_type_list
    - kwargs:
        cloud_name: admin_identity
