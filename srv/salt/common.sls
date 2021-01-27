# vim: set ft=yaml :

{%- for package in pillar['packages_install'] %}
{{ package }}:
  pkg.installed
{% endfor %}
