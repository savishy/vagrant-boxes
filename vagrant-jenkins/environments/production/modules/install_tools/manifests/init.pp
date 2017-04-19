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
      command => '/usr/bin/sudo /usr/bin/dpkg --add-architecture i386',
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

#install JDK 8
exec {'download-jdk-8':
  cwd => '/tmp',
  command => '/usr/bin/wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u92-linux-x64.tar.gz',
  creates => '/tmp/jdk-8u92-linux-x64.tar.gz'
}

}
