{%- from "rabbitmq/map.jinja" import server with context %}
{%- if server.enabled %}

rabbitmq_server:
  pkg.installed:
  - name: {{ server.pkg }}
  {%- if server.version is defined %}
  - version: {{ server.version }}
  {%- endif %}

rabbitmq_config:
  file.managed:
  - name: {{ server.config_file }}
  - source: salt://rabbitmq/files/rabbitmq.config
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - makedirs: True
  - mode: 440
  - require:
    - pkg: rabbitmq_server

rabbitmq_env:
  file.managed:
  - name: {{ server.env_file }}
  - source: salt://rabbitmq/files/rabbitmq-env.conf
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - mode: 640

{%- if grains.os_family == 'Debian' %}

rabbitmq_default_config:
  file.managed:
  - name: {{ server.default_file }}
  - source: salt://rabbitmq/files/default
  - template: jinja
  - user: rabbitmq
  - group: rabbitmq
  - mode: 440
  - require:
    - pkg: rabbitmq_server

{%- endif %}

{%- if grains.init == 'systemd' %}

rabbitmq_limits_systemd:
  file.managed:
  - name: {{ server.limits_file }}
  - source: salt://rabbitmq/files/limits.conf
  - template: jinja
  - user: root
  - group: root
  - makedirs: True
  - mode: 0644
  - require:
    - pkg: rabbitmq_server

rabbitmq_epmd_socket:
  service.dead:
  - name: epmd.socket
  - require:
    - pkg: rabbitmq_server

{%- endif %}

{%- if server.secret_key is defined and not grains.get('noservices', False) %}

{%- if salt['cmd.shell']('cat '+server.cookie_file) != server.secret_key %}

sleep_before_rabbitmq_stop:
  cmd.run:
  - name: sleep 30
  - user: root
  - require:
    - pkg: rabbitmq_server
    - file: rabbitmq_config
{#    - cmd: enable_mgmt_plugin #}

stop_rabbitmq_service:
  cmd.run:
  - name: service {{ server.service }} stop
  - require:
    - cmd: sleep_before_rabbitmq_stop

/var/lib/rabbitmq:
  file.directory

rabbitmq_cookie:
  file.managed:
  - name: {{ server.cookie_file }}
  - contents: {{ server.secret_key }}
  - user: rabbitmq
  - group: rabbitmq
  - mode: 400
  - require:
    - file: /var/lib/rabbitmq
    - cmd: stop_rabbitmq_service

{%- if grains.os_family == 'Arch' %}

/root/.erlang.cookie:
  file.managed:
  - contents: {{ server.secret_key }}
  - user: root
  - group: root
  - mode: 400

{%- endif %}

sleep_before_rabbitmq_start:
  cmd.run:
  - name: sleep 30
  - user: root
  - require:
    - cmd: stop_rabbitmq_service
  - watch_in:
    - service: rabbitmq_service

{%- endif %}

{%- endif %}

{%- if not grains.get('noservices', False) %}
rabbitmq_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - watch:
    - file: rabbitmq_config
    - file: rabbitmq_env
      {%- if grains.init == 'systemd' %}
    - file: rabbitmq_limits_systemd
      {%- endif %}
      {% if server.ssl.enabled %}
    - file: rabbitmq_cacertificate
    - file: rabbitmq_certificate
    - file: rabbitmq_server_key
    - file: rabbitmq_ssl_all_file
      {%- endif %}
{%- endif %}

{%- if grains.get('virtual_subtype', None) == "Docker" %}

rabbitmq_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://rabbitmq/files/entrypoint.sh
  - mode: 755

{%- endif %}

{%- endif %}