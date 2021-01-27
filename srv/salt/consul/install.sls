# vim: set ft=yaml :

consul extract:
  archive.extracted:
    - name: /usr/bin/
    - source: https://releases.hashicorp.com/consul/1.9.2/consul_1.9.2_linux_amd64.zip
    - source_hash: 5141b2e7f54b51e07601d2b4ff1853f1d9b8e26b26bfb55281a8c47d8581352e
    - enforce_toplevel: False
    - if_missing: /usr/bin/consul


consul user:
  user.present:
    - name: consul
    - home: /etc/consul.d


consul group:
  group.present:
    - name: consul


/etc/consul.d:
  file.directory:
    - user: consul
    - group: consul
    - mode: 0755


/opt/consul:
  file.directory:
    - user: consul
    - group: consul
    - mode: 0755


/etc/consul.d/consul.hcl:
  file.managed:
    - source: salt://consul/files/{{ pillar['consul_mode'] }}/consul.hcl.j2
    - user: consul
    - group: consul
    - mode: 0644
    - template: jinja


/etc/systemd/system/consul.service:
  file.managed:
    - contents: |
        [Unit]
        Description="HashiCorp Consul - A service mesh solution"
        Documentation=https://www.consul.io/
        Requires=network-online.target
        After=network-online.target
        ConditionFileNotEmpty=/etc/consul.d/consul.hcl
        
        [Service]
        Type=notify
        User=consul
        Group=consul
        ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
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
      - file: /etc/consul.d/consul.hcl
