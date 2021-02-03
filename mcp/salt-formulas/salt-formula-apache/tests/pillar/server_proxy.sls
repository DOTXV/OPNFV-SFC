apache:
  server:
    enabled: true
    bind:
      address: '0.0.0.0'
      ports:
      - 80
    modules:
    - proxy
    - proxy_http
    - proxy_balancer
    site:
      apache_proxy_site:
        enabled: true
        type: proxy
        name: site_name
        proxy:
          host: 127.0.0.1
          port: 8080
          protocol: http
          retry: 30
        host:
          name: 127.0.1.1
          port: 9001
          address: 127.0.1.1
