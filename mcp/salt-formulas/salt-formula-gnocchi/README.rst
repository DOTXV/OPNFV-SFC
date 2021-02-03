
==================================
Gnocchi Formula
==================================

Service Gnocchi description

Gnocchi is an open-source time series database. The problem that Gnocchi solves
is the storage and indexing of time series data and resources at a large scale.
This is useful in modern cloud platforms which are not only huge but also are
dynamic and potentially multi-tenant. Gnocchi takes all of that into account.


Sample Pillars
==============

.. note::
   Before deploying gnocchi, Apache2 should be configured to serve wsgi vhost for Gnocchi API.
   Example of Apache pillar with Gnocchi site:

.. code-block:: yaml

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
          gnocchi:
            enabled: false
            available: true
            type: wsgi
            name: gnocchi
            host:
              name: gnocchi.site.com
              address: 127.0.0.1
              port: 8041
            log:
              custom:
                format: >-
                  %v:%p %{X-Forwarded-For}i %h %l %u %t \"%r\" %>s %D %O \"%{Referer}i\" \"%{User-Agent}i\"
            wsgi:
              daemon_process: gnocchi-api
              processes: ${_param:gnocchi_api_workers}
              threads: 10
              user: gnocchi
              group: gnocchi
              display_name: '%{GROUP}'
              script_alias: '/ /usr/bin/gnocchi-api'
              application_group: '%{GLOBAL}'
              authorization: 'On'
        pkgs:
          - apache2
        modules:
          - wsgi

Single Gnocchi service with file storage backend

    gnocchi:
      server:
        enabled: true
        version: 4.0
        database:
          engine: mysql
          host: 127.0.0.1
          name: gnocchi
          password: workshop
          user: gnocchi
        storage:
          aggregation_workers: 2
          driver: file
          file_basepath: /var/lib/gnocchi
        coordination_backend:
          url: redis://127.0.0.1:6379/
        bind:
          address: 127.0.0.1
          port: 8041
        api:
          auth_mode: keystone
        identity:
          engine: keystone
          region: RegionOne
          protocol: http
          host: 127.0.0.1
          port: 35357
          user: gnocchi
          password: 127.0.0.1
        cache:
          engine: memcached
          members:
          - host: 127.0.0.1
            port: 11211

Single Gnocchi service with redis storage backend

.. code-block:: yaml

    gnocchi:
      server:
        enabled: true
        version: 4.0
        database:
          engine: mysql
          host: 127.0.0.1
          name: gnocchi
          password: workshop
          user: gnocchi
        storage:
          aggregation_workers: 2
          driver: redis
          redis_url: redis://127.0.0.1:6379/
        coordination_backend:
          url: redis://127.0.0.1:6379/
        bind:
          address: 127.0.0.1
          port: 8041
        api:
          auth_mode: keystone
        identity:
          engine: keystone
          region: RegionOne
          protocol: http
          host: 127.0.0.1
          port: 35357
          user: gnocchi
          password: 127.0.0.1
        cache:
          engine: memcached
          members:
          - host: 127.0.0.1
            port: 11211

Single Gnocchi service with redis backend for incoming storage and file backend for aggregated storage

.. code-block:: yaml

    gnocchi:
      server:
        enabled: true
        version: 4.0
        database:
          engine: mysql
          host: 127.0.0.1
          name: gnocchi
          password: workshop
          user: gnocchi
        storage:
          aggregation_workers: 2
          driver: file
          file_basepath: /var/lib/gnocchi
          incoming:
            driver: redis
            redis_url: redis://127.0.0.1:6379/
        coordination_backend:
          url: redis://127.0.0.1:6379/
        bind:
          address: 127.0.0.1
          port: 8041
        api:
          auth_mode: keystone
        identity:
          engine: keystone
          region: RegionOne
          protocol: http
          host: 127.0.0.1
          port: 35357
          user: gnocchi
          password: 127.0.0.1
        cache:
          engine: memcached
          members:
          - host: 127.0.0.1
            port: 11211

Single Gnocchi service with Gnocchi statsd on the same node:

.. code-block:: yaml

    gnocchi:
      common:
        version: 4.0
        database:
          engine: mysql
          host: 127.0.0.1
          name: gnocchi
          password: workshop
          user: gnocchi
        storage:
          aggregation_workers: 2
          driver: redis
          redis_url: redis://127.0.0.1/test
        coordination_backend:
          url: redis://127.0.0.1/test
      server:
        enabled: true
        bind:
          address: 127.0.0.1
          port: 8041
        api:
          auth_mode: keystone
          workers: 5
        identity:
          engine: keystone
          region: RegionOne
          protocol: http
          host: 127.0.0.1
          port: 35357
          user: gnocchi
          password: workshop
          tenant: service
        cache:
          engine: memcached
          members:
          - host: 127.0.0.1
            port: 11211
        metricd:
          workers: 5
      statsd:
        resource_id: 07f26121-5777-48ba-8a0b-d70468133dd9
        enabled: true
        bind:
          address: 127.0.0.1
          port: 8125

Gnocchi archive policy definition example:

.. code-block:: yaml

    gnocchi:
      client:
        enabled: True
        resources:
          v1:
            enabled: true
            cloud_name: admin_identity
            archive_policies:
              test_policy:
                definition:
                  - granularity: '1h'
                    points: 10
                    timespan: '10h'
                  - granularity: '2h'
                    points: 10
                    timespan: '20h'
                aggregation_methods:
                  - mean
                  - max
                back_window: 2
                rules:
                  test_policy_rule1:
                    metric_pattern: 'fo.*'
                  test_policy_rule2:
                    metric_pattern: 'foo2.*'

=======
Gnocchi logging configuration
----------------------------------

For enable fluend logging use

.. code-block:: yaml

  gnocchi:
    _support:
      fluentd:
        enabled: true

.. note:: Gnocchi doesnt support oslo.log options. So we cant use
   log_appender and log_handlers options

For change log_level or other log options

.. code-block:: yaml

  gnocchi:
    common:
      debug: true
      use_syslog: true
      use_journal: true
      log_dir: /var/log/gnocchi
      log_file: gnocchi.log

Enable x509 and ssl communication between Gnocchi and Galera cluster.
---------------------
By default communication between Gnocchi and Galera is unsecure.

gnocchi:
  common:
    database:
      x509:
        enabled: True

You able to set custom certificates in pillar:

gnocchi:
  common:
    database:
      x509:
        cacert: (certificate content)
        cert: (certificate content)
        key: (certificate content)

You can read more about it here:
    https://docs.openstack.org/security-guide/databases/database-access-control.html

Gnocchi server with memcached caching and security strategy:
-----------------------------
.. code-block:: yaml

    gnocchi:
      server:
        enabled: true
        ...
        cache:
          engine: memcached
          members:
          - host: 127.0.0.1
            port: 11211
          - host: 127.0.0.1
            port: 11211
          security:
            enabled: true
            strategy: ENCRYPT
            secret_key: secret

Setup redis coordination_backend url:
---------------------------
.. code-block:: yaml

    gnocchi:
      common:
        coordination_backend:
          engine: redis
          redis:
            password: pswd
            user: openstack
            db: '0'
            sentinel:
              host: 127.0.0.1
              master_name: master_1
              fallback:
                - host: 127.0.1.1
                - host: 127.0.2.1

Setup redis storage url:
-----------------------
.. code-block:: yaml

    gnocchi:
      common:
        storage:
          driver: redis
          redis:
            password: pswd
            user: openstack
            db: '0'
            sentinel:
              host: 127.0.0.1
              master_name: master_1
              fallback:
                - host: 127.0.1.1
                - host: 127.0.2.1

Setup redis incoming storage url:
---------------------------
.. code-block:: yaml

    gnocchi:
      common:
        storage:
          incoming:
            driver: redis
            redis:
              password: pswd
              user: openstack
              db: '0'
              sentinel:
                host: 127.0.0.1
                master_name: master_1
                fallback:
                  - host: 127.0.1.1
                  - host: 127.0.2.1

Change default options using configmap template settings
========================================================

.. code-block:: yaml

    gnocchi:
      common:
        configmap:
          DEFAULT:
            debug: false
            verbose: true
      server:
        configmap:
          DEFAULT:
            debug: false
            verbose: true
          api:
            paste_config: api-paste.ini
            max_limit: 1000
      statsd:
        configmap:
          DEFAULT:
            debug: false
            verbose: true
          statsd:
            host: 0.0.0.0
            port: 8125

More Information
================

* https://gnocchi.xyz/
