etcd:
  server:
    image: quay.io/coreos/etcd:latest
    enabled: true
    bind:
      host: 10.0.175.101
    token: $(uuidgen)
    members:
    - host: 10.0.175.101
      name: etcd01
      port: 4001
linux:
  system:
    enabled: true
    name: system_name
    env:
      enabled: false
    profile:
      enabled: false
    shell:
      enabled: false