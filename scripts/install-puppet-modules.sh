#!/bin/bash
for mod in "$@"; do
  if [[ "" = "$(/opt/puppetlabs/bin/puppet module list | grep $mod)" ]]; then
    sudo /opt/puppetlabs/bin/puppet module install "$mod"
  fi
done
