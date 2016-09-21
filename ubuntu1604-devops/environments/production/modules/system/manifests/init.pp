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
}
