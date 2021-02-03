{%- from "gnocchi/map.jinja" import server,statsd,client,upgrade with context %}

gnocchi_task_pkg_latest:
  test.show_notification:
    - text: "Running gnocchi.upgrade.pkg_latest"

policy-rc.d_present:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - mode: 755
    - contents: |
        #!/bin/sh
        exit 101

{%- set pkgs = [] %}
{%- if server.enabled %}
  {%- do pkgs.extend(server.pkgs) %}
  {# Gnocchi requires python-tenacity package which has no strict dependency on python-tornado #}
  {%- do pkgs.append('python-tornado') %}
{%- endif %}
{%- if statsd.enabled %}
  {%- do pkgs.extend(statsd.pkgs) %}
{%- endif %}
{%- if client.enabled %}
  {%- do pkgs.extend(client.pkgs) %}
{%- endif %}

gnocchi_pkg_latest:
  pkg.latest:
  - names: {{ pkgs|unique }}
  - require:
    - file: policy-rc.d_present
  - require_in:
    - file: policy-rc.d_absent

policy-rc.d_absent:
  file.absent:
    - name: /usr/sbin/policy-rc.d
