
==================================
etcd Formula
==================================

Service etcd description

Possible `source.engine`:

- **pkg** - install etcd package (default)
- **docker_hybrid** - copy binaries from docker image (specified in `server.image`)

Sample pillars
==============

Certificates
-------------

Use certificate authentication (for peers and clients). Certificates must be prepared in advance.

.. code-block:: yaml

    etcd:
      server:
        enabled: true
        ssl:
          enabled: true
        bind:
          host: 10.0.175.101
        token: $(uuidgen)
        members:
        - host: 10.0.175.101
          name: etcd01
          port: 4001

Single etcd service
---------------------

.. code-block:: yaml

    etcd:
      server:
        enabled: true
        bind:
          host: 10.0.175.101
        token: $(uuidgen)
        members:
        - host: 10.0.175.101
          name: etcd01
          port: 4001

Cluster etcd service
----------------------

.. code-block:: yaml

    etcd:
      server:
        enabled: true
        bind:
          host: 10.0.175.101
        token: $(uuidgen)
        members:
        - host: 10.0.175.101
          name: etcd01
          port: 4001
        - host: 10.0.175.102
          name: etcd02
          port: 4001
        - host: 10.0.175.103
          name: etcd03
          port: 4001

etcd proxy
-------------

.. code-block:: yaml

    etcd:
      server:
        enabled: true
        bind:
          host: 10.0.175.101
        proxy: true
        members:
        - host: 10.0.175.101
          name: etcd01
        - host: 10.0.175.102
          name: etcd02
        - host: 10.0.175.103
          name: etcd03

Run etcd on k8s
---------------

.. code-block:: yaml

    etcd:
      server:
        engine: kubernetes
        image: etcd:latest

Copy etcd binary from container
---------------

.. code-block:: yaml

    etcd:
      server:
        image: quay.io/coreos/etcd:latest

Read more
=========

* https://github.com/coreos/etcd
