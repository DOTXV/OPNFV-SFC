{%- from "gnocchi/map.jinja" import cfg with context %}

include:
 - gnocchi.upgrade.service_stopped
 - gnocchi.upgrade.pkgs_latest
 - gnocchi.upgrade.render_config
{%- if cfg.get('enabled', False) %}
 - gnocchi.backend.upgrade
{%- endif %}
 - gnocchi.upgrade.service_running
