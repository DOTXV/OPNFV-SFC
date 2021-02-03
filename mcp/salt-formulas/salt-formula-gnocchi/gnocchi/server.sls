{%- from "gnocchi/map.jinja" import server,cfg with context %}
{%- if server.get('enabled', False) %}

include:
  - apache
  - gnocchi._common
  - gnocchi.backend.upgrade

gnocchi_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}
  - require:
    - sls: gnocchi._common
  - require_in:
    - sls: gnocchi.backend.upgrade

apache_enable_gnocchi_wsgi:
  apache_site.enabled:
  - name: wsgi_gnocchi
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: gnocchi.backend.upgrade

gnocchi_apache_restart:
  service.running:
  - name: apache2
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - apache_enable_gnocchi_wsgi

gnocchi_server_services:
  service.running:
  - enable: true
  - names: {{ server.services }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: gnocchi.backend.upgrade
    - sls: gnocchi._common
  - watch:
    - gnocchi_common_conf

{%- endif %}
