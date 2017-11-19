# https://forge.puppet.com/elastic/elasticsearch

include java
class { 'elasticsearch':
  version => '6.0.0',
  restart_on_change => true,
  instances => {
    'es-01' => {
      'config' => {
        'network.host' => '0.0.0.0'
      }
    }
  }
}

class { 'kibana':
  config => {
    'server.host' => '0.0.0.0',
    'server.port' => '5601',
  }
}
