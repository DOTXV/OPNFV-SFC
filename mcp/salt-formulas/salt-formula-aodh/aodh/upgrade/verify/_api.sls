{%- from "aodh/map.jinja" import server with context %}

aodh_upgrade_verify_api:
  test.show_notification:
    - text: "Running aodh.upgrade.verify.api"

{%- if server.get('role', 'primary') == 'primary' %}
{% set Alarm_Name = 'testupgrade_alarm_name' %}
{% set Random_Uuid = salt['cmd.run']('cat /proc/sys/kernel/random/uuid') %}

aodhv2_alarm_present:
  aodhv2.alarm_present:
  - cloud_name: admin_identity
  - name: {{ Alarm_Name }}
  - type: gnocchi_resources_threshold
  - gnocchi_resources_threshold_rule:
      metric: cpu_util
      aggregation_method: mean
      threshold: '70.0'
      resource_id: {{ Random_Uuid }}
      resource_type: instance

aodhv2_alarm_list:
  module.run:
    - name: aodhv2.alarm_list
    - kwargs:
        cloud_name: admin_identity

aodhv2_alarm_absent:
  aodhv2.alarm_absent:
  - cloud_name: admin_identity
  - name: {{ Alarm_Name }}

{%- endif %}
