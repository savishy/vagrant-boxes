#!/bin/bash
set -e
# color for bash
# Typically just a matter of uncommenting.
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc

wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update -q
apt-get install -y puppet-agent

# update PATH
PATHSTR="export PATH=$PATH:/opt/puppetlabs/bin"
echo "$PATHSTR" >> /home/vagrant/.bashrc
eval $PATHSTR
# install puppet modules into vagrant's puppet environment
COMMON_ARGS=" --environment production --environmentpath /tmp/vagrant-puppet/environments "
puppet module install puppetlabs-stdlib $COMMON_ARGS
puppet module install nvogel-ansible $COMMON_ARGS
puppet module install garethr-docker $COMMON_ARGS
