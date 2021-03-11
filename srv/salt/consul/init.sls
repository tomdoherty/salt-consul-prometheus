# vim: set ft=yaml :

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import consul with context %}

consul extract:
  archive.extracted:
    - name: /usr/bin/
    - source: {{ consul.url }}
    - source_hash: {{ consul.sha }}
    - enforce_toplevel: False
    - if_missing: /usr/bin/consul


consul user:
  user.present:
    - name: {{ consul.user }}
    - home: {{ consul.home }}


consul group:
  group.present:
    - name: {{ consul.group }}


{{ consul.home }}:
  file.directory:
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - mode: 0755


/opt/consul:
  file.directory:
    - user: consul
    - group: consul
    - mode: 0755


{{ consul.home }}/consul.hcl:
  file.managed:
    - source: salt://consul/files/{{ pillar['consul_mode'] }}/consul.hcl.j2
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - mode: 0644
    - template: jinja


{{ consul.home }}/node_exporter.hcl:
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
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - mode: 0644


/etc/systemd/system/consul.service:
  file.managed:
    - contents: |
        [Unit]
        Description="HashiCorp Consul - A service mesh solution"
        Documentation=https://www.consul.io/
        Requires=network-online.target
        After=network-online.target
        ConditionFileNotEmpty={{ consul.home }}/consul.hcl
        
        [Service]
        Type=notify
        User={{ consul.user }}
        Group={{ consul.group }}
        ExecStart=/usr/bin/consul agent -config-dir={{ consul.home }}/
        ExecReload=/bin/kill --signal HUP $MAINPID
        KillMode=process
        KillSignal=SIGTERM
        Restart=on-failure
        LimitNOFILE=65536
        
        [Install]
        WantedBy=multi-user.target
    - user: root
    - group: root
    - mode: 0644


consul service:
  service.running:
    - name: consul
    - enable: True
    - reload: True
    - watch:
      - file: {{ consul.home }}/consul.hcl
      - file: {{ consul.home }}/node_exporter.hcl
