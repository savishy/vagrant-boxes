include git
include apt
# install common tools
class install_tools {

  # always update
  class { 'apt':
      update => {
        frequency => 'always'
      }
  } ~>
  exec{'add-architecture-i386':
      command => 'sudo /usr/bin/dpkg --add-architecture i386',
      notify => Exec['apt_update']
  }


  # Install Packages using the old style loop (because puppet < 4.0)

  # one-off defined resource type, in
  # /etc/puppetlabs/code/environments/production/modules/puppet/manifests/binary/symlink.pp
  define puppet::binary::pp ($binary = $title) {
    package { "$binary":
    ensure => 'latest'
  }
}

# TODO: Install pip
# TODO: Module for installing python modules.

# using defined type for iteration, somewhere else in your manifests
$binaries = [ "colordiff",
              "vim",
              "emacs",
              "git",
              "jq",
              "unzip",
              "zip",
              # 32-bit libraries for installing accurev if needed
              "libc6:i386",
              "libncurses5:i386",
              "libstdc++6:i386"]

puppet::binary::pp { $binaries: }


}
