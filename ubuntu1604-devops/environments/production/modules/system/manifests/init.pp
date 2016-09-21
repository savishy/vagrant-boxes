class system {
  package { "emacs":
      ensure => latest
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
