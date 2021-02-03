{%- from "barbican/map.jinja" import client with context %}

{%- set signed_images = client.get('signed_images', {}).get('v1', {}) %}

{%- if signed_images.get('enabled', False) %}

{%- for image, image_params in signed_images.get('images', {}).iteritems() %}

barbican_sign_image_{{ image_params.name }}:
  barbicanv1.glance_image_signed:
    - cloud_name: {{ image_params.cloud_name }}
    - name: {{ image_params.name }}
    - pk_fname: {{ image_params.cert_key }}
    - secret_name: {{ image_params.secret_name }}
    - out_fname: /tmp/signature_{{ image_params.name }}

{%- endfor %}
{%- endif %}
