class system {
  $packages = ["emacs", "vim", "curl", "wget"]
  $packages.each |$p| {
    package { "$p":
      ensure => latest
    }
  }
}
