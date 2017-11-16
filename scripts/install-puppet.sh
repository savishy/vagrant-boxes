#!/bin/bash
set -e
# color for bash
# Typically just a matter of uncommenting.
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc


# not installing puppet 4.6. see https://github.com/savishy/vagrant-boxes/issues/1

# This installs puppet for Ubuntu Trusty 14.04 only.

if [[ `dpkg-query -W -f='${Status}' puppet-common 2>&1` =~ "installed" ]]; then
  echo "puppet-common already installed; no action"
else
  INSTALL=1
fi
if [[ `dpkg-query -W -f='${Status}' puppet 2>&1` =~ "installed" ]]; then
  echo "puppet already installed; no action"
else
  INSTALL=1
fi

if [[ $INSTALL -eq 1 ]]; then
  echo "Installing Puppet ..."
  wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
  sudo dpkg -i puppetlabs-release-pc1-xenial.deb
  sudo apt-get update -qqy
  sudo apt-get install -y puppet-common #masterless puppet
  sudo apt-get install -y puppet        #masterful puppet
fi

# update PATH
PATHSTR="export PATH=$PATH:/opt/puppetlabs/bin"
echo "$PATHSTR" >> /home/vagrant/.bashrc
eval $PATHSTR
