include apt
# install common tools
class tools {


  $binaries = [
    "maven",
    "colordiff",
    "tree",
    "vim",
    "emacs",
    "git",
    "jq",
    "unzip",
    "zip"]

  $binaries.each |String $binary| {
    package { "${binary}":
    ensure => 'latest'
    }
  }


## install vagrant (I know, vagrant inside vagrant. But useful for provisioning
# AWS Boxes with Vagrant + Ansible)

  common::remote_file{'/tmp/vagrant_2.0.1_x64.deb':
    remote_location => 'https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.deb',
    mode            => '0777',
  } ~>
  package { "vagrant":
    provider => dpkg,
    ensure   => latest,
    source   => "/tmp/vagrant_2.0.1_x64.deb"
  }
}
