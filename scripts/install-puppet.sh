#!/bin/bash
set -e
# color for bash
# Typically just a matter of uncommenting.
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc


# not installing puppet 4.6. see https://github.com/savishy/vagrant-boxes/issues/1

# This installs puppet for Ubuntu Trusty 14.04 only.

if [[ `dpkg-query -W -f='${Status}' puppet-common` =~ "installed" ]]; then
  echo "puppet-common already installed; no action"
else
  INSTALL=0
fi
if [[ `dpkg-query -W -f='${Status}' puppet` =~ "installed" ]]; then
  echo "puppet already installed; no action"
else
  INSTALL=0
fi

if [[ $INSTALL -eq 1 ]]; then
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  sudo dpkg -i puppetlabs-release-precise.deb
  apt-get update -qqy
  apt-get install -y puppet-common #masterless puppet
  apt-get install -y puppet        #masterful puppet
fi

# update PATH
PATHSTR="export PATH=$PATH:/opt/puppetlabs/bin"
echo "$PATHSTR" >> /home/vagrant/.bashrc
eval $PATHSTR
echo "installing puppet modules"

# install puppet modules into vagrant's puppet environment
# install only if needed.
for module in puppetlabs-stdlib nvogel-ansible puppetlabs-apt; do
  { puppet module list | grep $module > /dev/null; } || \
  puppet module install $module
done
