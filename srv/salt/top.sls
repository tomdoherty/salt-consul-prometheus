# vim: set ft=yaml :

base:
  '*':
    - common
    - consul.install
    - node_exporter.install
  'master':
    - prometheus.install
