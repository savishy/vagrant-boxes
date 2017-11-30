include apt
require 'facter'
class install_docker {


  # create docker group
  group { 'docker':
    ensure => 'present'
  }

  # declare vagrant user as a virtual resource
  # http://serverfault.com/a/416284/135880
  # https://docs.puppet.com/puppet/latest/reference/lang_virtual.html#declaring-a-virtual-resource
  @user { 'vagrant':
    groups     => ['vagrant','docker'],
  }

  # realize virtual resource above.
  realize(User['vagrant'])

  # always update
  class { 'apt':
      update => {
        frequency => 'always'
      }
  }

  # docker key
  # apt::key {'58118E89F3A912897C070ADBF76221572C52609D':
  #   options => '--keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D',
  # } ->  # docker source

  # apt::key {'58118E89F3A912897C070ADBF76221572C52609D':
  #   id => '58118E89F3A912897C070ADBF76221572C52609D',
  #   server => 'hkp://ha.pool.sks-keyservers.net:80',
  # }

  apt::key {'9DC858229FC7DD38854AE2D88D81803C0EBFCD88':
    source => 'https://download.docker.com/linux/ubuntu/gpg',
  } ~>
  package { 'docker':
    ensure => 'absent'
  } ~>
  package { 'docker-engine':
    ensure => 'absent'
  } ~>
  package { 'docker.io':
    ensure => 'absent'
  } ~>
  apt::source { 'docker':
  location => 'https://download.docker.com/linux/ubuntu',
  repos    => 'stable',
  release  => 'xenial',
  architecture => 'amd64',
  notify  => Exec['apt_update'],
  } ~>  # packages needed for docker
  package { 'apt-transport-https':
    ensure => 'latest',
    require => Exec['apt_update']
  } ~>
  package { 'ca-certificates':
    ensure => 'latest'
  } ~>
  package {"linux-image-extra-$kernelrelease":
    ensure => 'latest'
  } ~>
  package {'linux-image-extra-virtual':
    ensure => 'latest'
  } ~>  # install docker
  package {"docker-ce":
    ensure => 'latest'
  } ~>
  file {'/etc/systemd/system/docker.service.d/':
    ensure => directory,
    mode => '0644',
    owner => 'root',
    group => 'root'
  } ~>
  file {'/etc/systemd/system/docker.service.d/docker.conf':
    ensure => file,
    content => template('install_docker/docker.conf.systemd'),
    mode => '0644',
    owner => 'root',
    group => 'root',
    notify => Service['docker'],
  } ~>
  exec { 'systemd-reload':
  command     => 'systemctl daemon-reload',
  path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
  refreshonly => true,
}
  # ensure docker service running.
  service {'docker':
    ensure => 'running'
  }
  # download docker compose
  common::remote_file{'/usr/local/bin/docker-compose':
    remote_location => 'https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64',
    mode            => '0777',
  }

}
