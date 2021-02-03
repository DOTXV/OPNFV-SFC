{%- from "barbican/map.jinja" import server with context %}

barbican_plugin_ssl:
  test.show_notification:
    - text: "Running barbican._ssl.plugin"

{%- if server.get('plugin', {}).get('vault', {}).get('schema', 'http') == 'https' %}

  {%- set ca_file=server.plugin.vault.ssl_ca_crt_file %}

barbican_plugin_vault_ca:
  {%- if server.plugin.vault.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: barbican:server:plugin:vault:cacert
    - mode: 444
    - user: barbican
    - group: barbican
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

barbican_plugin_vault_ca_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
    - mode: 444
    - user: barbican
    - group: barbican

{%- endif %}
