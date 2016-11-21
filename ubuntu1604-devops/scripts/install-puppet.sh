#!/bin/bash
set -e
# color for bash
# Typically just a matter of uncommenting.
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc


# not installing puppet 4.6. see https://github.com/savishy/vagrant-boxes/issues/1

#wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
#dpkg -i puppetlabs-release-pc1-xenial.deb
#echo "installing puppet"
#apt-get update -qq
#apt-get install -qqy puppet

wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
apt-get update
apt-get install -y puppet-common #masterless puppet
apt-get install -y puppet        #masterful puppet

# update PATH
PATHSTR="export PATH=$PATH:/opt/puppetlabs/bin"
echo "$PATHSTR" >> /home/vagrant/.bashrc
eval $PATHSTR
echo "installing puppet modules"
# install puppet modules into vagrant's puppet environment
puppet module install puppetlabs-stdlib
puppet module install nvogel-ansible
puppet module install garethr-docker
