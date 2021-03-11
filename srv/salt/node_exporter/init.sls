# vim: set ft=yaml :

node_exporter extract:
  archive.extracted:
    - name: /tmp
    - source: https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
    - source_hash: sha256=3369b76cd2b0ba678b6d618deab320e565c3d93ccb5c2a0d5db51a53857768ae 


node_exporter binary:
  file.copy:
    - name: /usr/sbin/node_exporter
    - source: /tmp/node_exporter-1.0.1.linux-amd64/node_exporter


/etc/systemd/system/node_exporter.service:
  file.managed:
    - source: salt://node_exporter/files/node_exporter.service
    - user: root
    - group: root
    - mode: 0644


/etc/consul.d/node_exporter.hcl:
  file.managed:
    - contents: |
        {
          "service": {
            "name": "node_exporter",
            "tags": [
              "node_exporter",
              "prometheus"
            ],
            "port": 9100,
            "checks": [
              {
                "http": "http://localhost:9100/metrics",
                "interval": "10s",
                "timeout": "1s"
              }
            ],
          }
        }
    - user: consul
    - group: consul
    - mode: 0644


node_exporter service:
  service.running:
    - name: node_exporter
    - enable: True
    - reload: True
