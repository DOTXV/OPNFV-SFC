{%- from "gnocchi/map.jinja" import server,statsd,upgrade with context %}

gnocchi_task_service_running:
  test.show_notification:
    - text: "Running gnocchi.upgrade.service_running"

{%- set gservices = [] %}
{%- if server.enabled %}
  {%- set gservices = ['apache2'] %}
  {%- do gservices.extend(server.services) %}
{%- endif %}
{%- if statsd.enabled %}
  {%- do gservices.extend(statsd.services) %}
{%- endif %}


{%- for gservice in gservices %}
gnocchi_service_running_{{ gservice }}:
  service.running:
  - name: {{ gservice }}
  - enable: True
{%- endfor %}
