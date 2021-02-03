{%- from "gnocchi/map.jinja" import server,statsd,upgrade with context %}

gnocchi_task_service_stopped:
  test.show_notification:
    - text: "Running gnocchi.upgrade.service_stopped"

{%- set gservices = [] %}
{%- if server.enabled %}
  {%- set gservices = ['apache2'] %}
  {%- do gservices.extend(server.services) %}
{%- endif %}
{%- if statsd.enabled %}
  {%- do gservices.extend(statsd.services) %}
{%- endif %}


{%- for gservice in gservices %}
gnocchi_service_stopped_{{ gservice }}:
  service.dead:
  - name: {{ gservice }}
  - enable: False
{%- endfor %}
