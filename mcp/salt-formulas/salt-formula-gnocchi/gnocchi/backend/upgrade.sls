{%- from "gnocchi/map.jinja" import server with context %}

gnocchi_upgrade:
  cmd.run:
  - name: gnocchi-upgrade
  {%- if grains.get('noservices') or server.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: gnocchi