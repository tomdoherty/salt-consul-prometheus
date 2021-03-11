# Salt+Consul+Prometheus

Playing with [SaltStack](https://www.saltstack.com), [Consul](https://www.consul.io), & [Prometheus](https://prometheus.io)


```shell
$ vagrant up
$ vagrant ssh master

master$ sudo salt-key -Ay
master$ sudo salt '*' state.highstate
```

Will bring up 1x master running Consul & Prometheus in addition to 3x minion running node_exporter.

[Consul UI](http://192.168.33.10:8500)

[Prometheus](http://192.168.33.10:9090/graph)
