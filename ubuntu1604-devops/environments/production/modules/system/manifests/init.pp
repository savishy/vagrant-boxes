class system {
  package { "emacs":
      ensure => latest
    }
  file { 'emacs config':
    path => '/home/vagrant',
    source => 'puppet:///modules/system/emacs',
    recurse => true
  }
  package { "vim":
      ensure => latest
    }
  package { "curl":
      ensure => latest
    }
  package { "wget":
      ensure => latest
    }
  package { "tar":
      ensure => latest
    }
  package { "zip":
      ensure => latest
    }
  package { "unzip":
      ensure => latest
    }
}
