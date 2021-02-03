{%- from "aodh/map.jinja" import server with context %}

aodh_syncdb:
  cmd.run:
  - name: aodh-dbsync
  - runas: 'aodh'
  {%- if grains.get('noservices') or server.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
