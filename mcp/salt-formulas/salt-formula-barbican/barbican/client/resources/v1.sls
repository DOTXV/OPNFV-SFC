{%- from "barbican/map.jinja" import client with context %}

{%- set resources = client.get('resources', {}).get('v1', {}) %}

{%- if resources.get('enabled', False) %}

{%- for secret_name, secret in resources.get('secrets', {}).iteritems() %}

{%- set payload = '' %}
{%- if secret.payload is defined %}
{%- set payload = secret.payload %}
{%- elif secret.payload_path is defined %}
{%- set payload = salt['cmd.shell']('cat '+secret.payload_path) %}
{%- endif %}

barbican_secret_{{ secret_name }}:
  barbicanv1.secret_present:
  - cloud_name: {{ secret.get('cloud_name', resources.cloud_name) }}
  - name: {{ secret_name }}
  - algorithm: {{ secret.algorithm}}
  - secret_type: {{ secret.type }}
{%- if payload %}
{%- if secret.get('encodeb64_payload', False) %}
{%- set payload = salt['hashutil.base64_b64encode'](payload) %}
  - payload_content_encoding: base64
{%- elif secret.payload_content_encoding is defined %}
  - payload_content_encoding: {{ secret.payload_content_encoding }}
{%- endif %}
  - payload: {{ payload }}
  - payload_content_type: {{ secret.payload_content_type }}
{%- endif %}
{%- endfor %}

{%- for secret_name, users_info in resources.get('acl', {}).iteritems() %}

{%- set users = salt['keystonev3.user_list'](cloud_name=users_info.get('cloud_name', resources.cloud_name)) %}

barbican_secret_acl_add_user_{{ secret_name }}:
  barbicanv1.secret_acl_present:
    - name: {{ secret_name }}
    - cloud_name: {{ users_info.get('cloud_name', resources.cloud_name) }}
    - users:
{%- for user in users['users'] %}
{%- for user_name, enabled in users_info.iteritems() %}
{%- if user_name == user['name'] and enabled %}
         - {{ user['id'] }}
{%- endif %}
{%- endfor %}
{%- endfor %}
    - project-access: True

{%- endfor %}

{%- endif %}
