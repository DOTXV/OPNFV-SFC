{%- from "rabbitmq/map.jinja" import server with context %}

rabbitmq_task_pkgs_latest:
  test.show_notification:
    - name: "dump_message_pkgs_latest"
    - text: "Running rabbitmq.upgrade.pkg_latest"

policy-rc.d_present:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - mode: 755
    - contents: |
        #!/bin/sh
        exit 101

{%- if server.get('enabled', false) %}
  {%- if server.version is defined %}
rabbitmq_packages:
  pkg.installed:
  - name: {{ server.pkg }}
  - version: {{ server.version }}
  - require:
    - file: policy-rc.d_present
  - require_in:
    - file: policy-rc.d_absent
  {%- else %}
rabbitmq_packages:
  pkg.latest:
  - name: {{ server.pkg }}
  - require:
    - file: policy-rc.d_present
  - require_in:
    - file: policy-rc.d_absent
  {%- endif %}
{%- endif %}

policy-rc.d_absent:
  file.absent:
    - name: /usr/sbin/policy-rc.d
