include apt
class install_ansible {
  package { 'software-properties-common':
    ensure => installed,
  }
  apt::ppa {'ppa:ansible/ansible':
    require => Package['software-properties-common'],
    notify => Exec['apt_update']
  }
  package { 'ansible':
    ensure => latest
  }
}
