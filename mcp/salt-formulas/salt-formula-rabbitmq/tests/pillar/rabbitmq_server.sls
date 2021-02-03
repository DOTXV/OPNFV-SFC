rabbitmq:
  server:
    enabled: true
    bind:
      address: 0.0.0.0
      port: 5672
    secret_key: rabbit_master_cookie
    admin:
      name: adminuser
      password: pwd
      service: rabbitmq-server
    host:
      '/':
        enabled: true
        user: guest
        password: guest
        policies:
        - name: HA
          pattern: '^(?!amq\.).*'
          definition: '{"ha-mode": "all"}'
    memory:
      vm_high_watermark: 0.4
    plugins_runas_user: root
    plugins:
    - amqp_client
    - rabbitmq_management
    env_variables:
      hostname: localhost
      export:
        home: /var/lib/rabbitmq
