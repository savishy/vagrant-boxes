include apt
class jenkins-setup {

  # https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu
  # add jenkins key
  exec { 'jenkins-key':
    command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -'
    } ~>
  exec { '/etc/apt/sources.list.d/jenkins.list':
    command => '/bin/echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  } ~>
  apt::key { 'puppet gpg key':
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      server => 'hkp://pgp.mit.edu:80',
    } ~>


  package { 'openjdk-7-jdk':
      ensure => 'latest',
      require => Exec['apt_update']
  } ~>
  package { 'jenkins':
      ensure => 'latest'
  } ~>   # deploy templated docker conf.
  file {'/etc/default/jenkins':
    ensure => file,
    content => template('jenkins-setup/jenkins_defaults'),
    notify => Service['jenkins'],
    mode => '0644',
    owner => 'root',
    group => 'root'
  } ~>
  service { 'jenkins':
    ensure => 'running'
  }

}
