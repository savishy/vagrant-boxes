include git
# install common tools
class install_tools {

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
$binaries = ["colordiff","vim","emacs","git", "jq", "unzip", "zip"]

puppet::binary::pp { $binaries: }

## install vagrant (I know, vagrant inside vagrant. But useful for provisioning
# AWS Boxes with Vagrant + Ansible)

common::remote_file{'/tmp/vagrant_1.9.3_x64.deb':
remote_location => 'https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb',
mode            => '0777',
} ~>
package { "vagrant":
provider => dpkg,
ensure   => latest,
source   => "/tmp/vagrant_1.9.3_x64.deb"
} ~>
exec { "vagrant-aws":
  command => "vagrant plugin install vagrant-aws",
}


}
