{%- from "gnocchi/map.jinja" import server with context %}


gnocchi_upgrade_verify_api:
  test.show_notification:
    - text: "Running gnocchi.upgrade.verify.api"

{%- if server.get('role', 'primary') == 'primary' %}
  {%- set archive_policy_name = 'test_upgrade_policy' %}
  {%- set archive_policy_rule_name = archive_policy_name + '_rule' %}
gnocchi_archive_policy_create:
  module.run:
    - name: gnocchiv1.archive_policy_create
    - kwargs:
        name: {{ archive_policy_name }}
        definition:
          - granularity: '1h'
            points: 100
            timespan: '100h'
          - granularity: '2h'
            points: 100
            timespan: '200h'
        aggregation_methods:
          - mean
          - count
          - max
        back_window: 2
        cloud_name: admin_identity

gnocchi_archive_policy_list:
  module.run:
    - name: gnocchiv1.archive_policy_list
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_create

gnocchi_archive_policy_read:
  module.run:
    - name: gnocchiv1.archive_policy_read
    - args:
      - {{ archive_policy_name }}
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_list

gnocchi_archive_policy_update:
  module.run:
    - name: gnocchiv1.archive_policy_update
    - args:
      - {{ archive_policy_name }}
    - kwargs:
        cloud_name: admin_identity
        definition:
          - granularity: '1h'
            points: 300
            timespan: '300h'
          - granularity: '2h'
            points: 400
            timespan: '800h'
    - require:
      - gnocchi_archive_policy_read

gnocchi_archive_policy_rule_create:
  module.run:
    - name: gnocchiv1.archive_policy_rule_create
    - kwargs:
        name: {{ archive_policy_rule_name }}
        archive_policy_name: {{ archive_policy_name }}
        metric_pattern: 'disk.*'
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_update

gnocchi_archive_policy_rule_list:
  module.run:
    - name: gnocchiv1.archive_policy_rule_list
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_rule_create

gnocchi_archive_policy_rule_read:
  module.run:
    - name: gnocchiv1.archive_policy_rule_read
    - args:
      - {{ archive_policy_rule_name }}
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_rule_list

gnocchi_archive_policy_rule_delete:
  module.run:
    - name: gnocchiv1.archive_policy_rule_delete
    - args:
      - {{ archive_policy_rule_name }}
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_rule_list

gnocchi_archive_policy_delete:
  module.run:
    - name: gnocchiv1.archive_policy_delete
    - args:
      - {{ archive_policy_name }}
    - kwargs:
        cloud_name: admin_identity
    - require:
      - gnocchi_archive_policy_rule_delete
{%- endif %}
