# vim: set ft=yaml :

base:
  '*':
    - common
  'master':
    - controller
  'minion-*':
    - worker
