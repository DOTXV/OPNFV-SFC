{%- from "gnocchi/map.jinja" import cfg,upgrade with context %}

gnocchi_render_config:
  test.show_notification:
    - text: "Running gnocchi.upgrade.render_config"

{%- if cfg.get('enabled', false) %}
/etc/gnocchi/gnocchi.conf:
  file.managed:
  - source: salt://gnocchi/files/{{ upgrade.new_release }}/gnocchi.conf
  - template: jinja
{%- endif %}
