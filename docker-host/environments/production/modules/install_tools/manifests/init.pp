# install common tools
class install_tools {

  # one-off defined resource type, in
# /etc/puppetlabs/code/environments/production/modules/puppet/manifests/binary/symlink.pp
define puppet::binary::pp ($binary = $title) {
  package {"$binary":
    ensure => 'latest'
  }
}

# using defined type for iteration, somewhere else in your manifests
$binaries = ["colordiff","vim","emacs","git"]

puppet::binary::pp { $binaries: }
}
