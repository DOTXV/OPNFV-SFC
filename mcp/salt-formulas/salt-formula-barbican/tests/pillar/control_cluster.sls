barbican:
  server:
    enabled: true
    version: ocata
    host_href: ''
    is_proxied: true
    dogtag_admin_cert:
      engine: manual
      key: 'some dogtag key'
    plugin:
      simple_crypto:
        kek: "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY="
      p11_crypto:
        library_path: '/usr/lib/libCryptoki2_64.so'
        login: 'mypassword'
        mkek_label: 'an_mkek'
        mkek_length: 32
        hmac_label: 'my_hmac_label'
      kmip:
        username: 'admin'
        password: 'password'
        host: localhost
        port: 5696
        keyfile: '/path/to/certs/cert.key'
        certfile: '/path/to/certs/cert.crt'
        ca_certs: '/path/to/certs/LocalCA.crt'
      dogtag:
        pem_path: '/etc/barbican/kra_admin_cert.pem'
        dogtag_host: localhost
        dogtag_port: 8443
        nss_db_path: '/etc/barbican/alias'
        nss_db_path_ca: '/etc/barbican/alias-ca'
        nss_password: 'password123'
        simple_cmc_profile: 'caOtherCert'
        ca_expiration_time: 1
        plugin_working_dir: '/etc/barbican/dogtag'
    store:
      software:
        crypto_plugin: simple_crypto
        store_plugin: store_crypto
        global_default: True
      kmip:
        store_plugin: kmip_plugin
      dogtag:
        store_plugin: dogtag_crypto
      pkcs11:
        store_plugin: store_crypto
        crypto_plugin: p11_crypto
    database:
      engine: "mysql+pymysql"
      host: 10.0.106.20
      port: 3306
      name: barbican
      user: barbican
      password: password
    bind:
      address: 10.0.106.20
      port: 9311
      admin_port: 9312
    identity:
      engine: keystone
      host: 10.0.106.20
      port: 35357
      domain: default
      tenant: service
      user: barbican
      password: password
    message_queue:
      engine: rabbitmq
      user: openstack
      password: password
      virtual_host: '/openstack'
      members:
      - host: 10.10.10.10
        port: 5672
      - host: 10.10.10.11
        port: 5672
      - host: 10.10.10.12
        port: 5672
    cache:
      engine: memcached
      expiration_time: 600
      backend_argument:
        memcached_expire_time:
          value: 660
      members:
      - host: 10.10.10.10
        port: 11211
      - host: 10.10.10.11
        port: 11211
      - host: 10.10.10.12
        port: 11211
      security:
        enabled: true
        strategy: ENCRYPT
        secret_key: secret
    logging:
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: false
        fluentd:
          enabled: false
        ossyslog:
          enabled: false
    configmap:
      DEFAULT:
        max_allowed_secret_in_bytes: 10000
        max_allowed_request_size_in_bytes: 1000000
        sql_pool_max_overflow: 10
        default_limit_paging: 10
        max_limit_paging: 100
      quotas:
        quota_secrets: -1
        quota_orders: -1
        quota_containers: -1
        quota_consumers: -1
        quota_cas: -1
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      barbican:
        enabled: false
        available: true
        type: wsgi
        name: barbican
        wsgi:
          daemon_process: barbican-api
          processes: 3
          threads: 10
          user: barbican
          group: barbican
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/barbican-wsgi-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 9311
      barbican_admin:
        enabled: false
        available: true
        type: wsgi
        name: barbican_admin
        wsgi:
          daemon_process: barbican-api-admin
          processes: 3
          threads: 10
          user: barbican
          group: barbican
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/barbican-wsgi-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 9312
