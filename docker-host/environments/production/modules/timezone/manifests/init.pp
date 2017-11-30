class timezone {
  file { '/etc/timezone':
          ensure => present,
          content => "Asia/Kolkata\n",
  }

  exec { 'reconfigure-tzdata':
          user => root,
          group => root,
          command => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
  }

  notify { 'timezone-changed':
          message => 'Timezone was updated to Asia/Kolkata',
  }

  File['/etc/timezone'] -> Exec['reconfigure-tzdata'] -> Notify['timezone-changed']

}
