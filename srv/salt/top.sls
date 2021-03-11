# vim: set ft=yaml :

base:
  '*':
    - common
    - consul
    - node_exporter
  'master':
    - prometheus
