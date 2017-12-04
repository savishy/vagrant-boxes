#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
# not installing puppet 4.6. see https://github.com/savishy/vagrant-boxes/issues/1
# This installs puppet for Ubuntu only.

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
  sudo apt-get install -y wget unzip
  wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
  sudo dpkg -i puppetlabs-release-pc1-xenial.deb
  sudo apt-get update -qqy
  sudo apt-get install -y puppetserver
fi

# update PATH
if [[ -d "/home/vagrant/" ]]; then
  PATHSTR="export PATH=$PATH:/opt/puppetlabs/bin"
  echo "$PATHSTR" >> /home/vagrant/.bashrc
  eval $PATHSTR
fi
