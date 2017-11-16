## Vagrant box: Elasticsearch-Kibana

This is an initial attempt at a Vagrant box that creates a ready-to-go environment with Elasticsearch and Kibana.

### Tested with

* Vagrant 2.0.1
* Virtualbox 5.1.30
* Windows 10 x64

### Virtualizations

Only Virtualbox is supported.

### Versions

* Base OS: Ubuntu 16.04
* Provisioner: Puppet 5.3.3
* Kibana: 6.0
* Elasticsearch: 6.0
* OpenJDK: 1.8.0

### Ports

* Kibana: 5601
* Elasticsearch: 9200

## How to run

```
cd vagrant-elk
vagrant up
```

## References
1. https://github.com/comperiosearch/vagrant-elk-box
1. https://docs.docker.com/engine/admin/logging/fluentd/
1. https://forge.puppet.com/elastic/kibana
