# https://forge.puppet.com/elastic/elasticsearch

include java
class { 'elasticsearch':
  version => '6.0.0',
  restart_on_change => true
}
elasticsearch::instance { 'es-01': }

class { 'kibana':
  config => {
    'server.host' => '0.0.0.0',
    'server.port' => '5601',
  }
}
