# vim: set ft=yaml :

prometheus extract:
  archive.extracted:
    - name: /tmp
    - source: https://github.com/prometheus/prometheus/releases/download/v2.24.1/prometheus-2.24.1.linux-amd64.tar.gz
    - source_hash: sha256=5aec10296624449e83469ef647cb762bd4de2aa12fc91d2375c5e6be9fd049c0


prometheus user:
  user.present:
    - name: prometheus
    - home: /etc/prometheus


prometheus group:
  group.present:
    - name: prometheus


/var/lib/prometheus:
  file.directory:
    - user: prometheus
    - group: prometheus
    - mode: 0755

prometheus binary:
  file.copy:
    - name: /usr/sbin/prometheus
    - source: /tmp/prometheus-2.24.1.linux-amd64/prometheus


promtool binary:
  file.copy:
    - name: /usr/sbin/promtool
    - source: /tmp/prometheus-2.24.1.linux-amd64/promtool


install console_libraries:
  file.copy:
    - name: /etc/prometheus/console_libraries
    - source: /tmp/prometheus-2.24.1.linux-amd64/console_libraries


install consoles:
  file.copy:
    - name: /etc/prometheus/consoles
    - source: /tmp/prometheus-2.24.1.linux-amd64/consoles


/etc/systemd/system/prometheus.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Prometheus
        Wants=network-online.target
        After=network-online.target
        
        [Service]
        User=prometheus
        Group=prometheus
        Type=simple
        ExecStart=/usr/sbin/prometheus \
            --config.file /etc/prometheus/prometheus.yml \
            --storage.tsdb.path /var/lib/prometheus/ \
            --web.console.templates=/etc/prometheus/consoles \
            --web.console.libraries=/etc/prometheus/console_libraries
        
        [Install]
        WantedBy=multi-user.target
    - user: root
    - group: root
    - mode: 0644


/etc/prometheus/prometheus.yml:
  file.managed:
    - contents: |
        global:
          scrape_interval:     15s
          evaluation_interval: 15s
        
        scrape_configs:
          - job_name: 'prometheus'
            consul_sd_configs:
              - server: 'localhost:8500'
            relabel_configs:
              - source_labels: [__meta_consul_tags]
                regex: .*,prometheus,.*
                action: keep
              - source_labels: [__meta_consul_service]
                target_label: job


/etc/consul.d/prometheus.hcl:
  file.managed:
    - contents: |
        {
          "service": {
            "name": "prometheus",
            "tags": [
              "prometheus"
            ],
            "port": 9090,
            "checks": [
              {
                "http": "http://localhost:9090/metrics",
                "interval": "10s",
                "timeout": "1s"
              }
            ],
          }
        }
    - user: consul
    - group: consul
    - mode: 0644


prometheus service:
  service.running:
    - name: prometheus
    - enable: True
    - reload: True
