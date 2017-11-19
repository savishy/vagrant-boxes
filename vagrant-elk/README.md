## Vagrant box: Elasticsearch-Kibana

This is an initial attempt at a Vagrant box that creates a ready-to-go environment with Elasticsearch and Kibana.

### Tested with

* Vagrant 2.0.1
* Virtualbox 5.1.30
* Windows 10 x64
* 16 GB RAM on host machine (*the VM requires 4GB based on experience*)

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

### Bring up the vagrant box

```
git clone http://github.com/savishy/vagrant-boxes
cd vagrant-boxes/vagrant-elk
vagrant up
```

This brings up a Linux VM and provisions Elasticsearch and Kibana into it.

### Verify Kibana

* Kibana takes a few minutes to initialize. Wait for a few min.
* Then Load either `http://84.84.87.95:5601` or `http://localhost:5601` in a browser in your host machine.

Next, to verify API access, from outside the box, execute:

```
curl -X GET http://84.84.87.95:5601

<script>var hashRoute = '/app/kibana';
var defaultRoute = '/app/kibana';

var hash = window.location.hash;
if (hash.length) {
  window.location = hashRoute + hash;
} else {
  window.location = defaultRoute;
}</script>
```

### Verify Elasticsearch

From outside the box, execute:

```
curl -X GET http://84.84.87.95:9200
```

## References
1. https://github.com/comperiosearch/vagrant-elk-box
1. https://docs.docker.com/engine/admin/logging/fluentd/
1. https://forge.puppet.com/elastic/kibana
