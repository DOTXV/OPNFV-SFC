{%- from "panko/map.jinja" import server with context %}

{%- if server.get('enabled', False) %}

include:
  - apache
  - panko._ssl.mysql
  - panko.db.offline_sync

panko_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}
  - require_in:
    - sls: panko._ssl.mysql
    - sls: panko.db.offline_sync

/etc/panko/panko.conf:
  file.managed:
  - source: salt://panko/files/{{ server.version }}/panko.conf.{{ grains.os_family }}
  - template: jinja
  - mode: 0640
  - group: panko
  - require:
    - sls: panko._ssl.mysql
    - pkg: panko_server_packages
  - require_in:
    - sls: panko.db.offline_sync

{% if server.logging.log_appender %}

{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
panko_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

/var/log/panko/panko.log:
  file.managed:
    - user: panko
    - group: panko

panko_general_logging_conf:
  file.managed:
    - name: /etc/panko/logging.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - user: panko
    - group: panko
    - defaults:
        service_name: panko
        _data: {{ server.logging }}
    - require:
      - pkg: panko_server_packages
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: panko_fluentd_logger_package
{%- endif %}
    - require_in:
      - sls: panko.db.offline_sync
    - watch_in:
      - service: panko_apache_restart
{% endif %}

{%- if server.get('role', 'secondary') == 'primary' %}
{%- set cron = server.expirer.cron %}
panko_expirer_cron:
  cron.present:
    {#- By default expirer will write logs to stderr, so redirecting them to syslog #}
    - name: /usr/bin/panko-expirer {% if not server.logging.log_appender %}--use-syslog{% endif %}
    - user: panko
    - minute: '{{ cron.minute }}'
    {%- if cron.hour is defined %}
    - hour: '{{ cron.hour }}'
    {%- endif %}
    {%- if cron.daymonth is defined %}
    - daymonth: '{{ cron.daymonth }}'
    {%- endif %}
    {%- if cron.month is defined %}
    - month: '{{ cron.month }}'
    {%- endif %}
    {%- if cron.dayweek is defined %}
    - dayweek: '{{ cron.dayweek }}'
    {%- endif %}
    - require:
      - file: /etc/panko/panko.conf
{%- endif %}

{#- Creation of sites using templates is deprecated, sites should be generated by apache pillar, and enabled by panko formula #}
{%- if pillar.get('apache', {}).get('server', {}).get('site', {}).panko is defined %}

apache_enable_panko_wsgi:
  apache_site.enabled:
  - name: wsgi_panko
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - pkg: panko_server_packages

{%- else %}

/etc/apache2/sites-available/panko-api.conf:
  file.managed:
  - source: salt://panko/files/{{ server.version }}/panko-api.apache2.conf.Debian
  - template: jinja
  - require:
    - pkg: panko_server_packages

apache_enable_panko_wsgi:
  apache_site.enabled:
  - name: panko-api
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/apache2/sites-available/panko-api.conf

{%- endif %}

panko_apache_restart:
  service.running:
  - enable: true
  - name: {{ server.service_name }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/panko/panko.conf
    - apache_enable_panko_wsgi
  - require:
    - sls: panko._ssl.mysql
    - sls: panko.db.offline_sync

{%- endif %}
