#!/bin/bash

for mod in "$@"; do
  echo $mod
  puppet module list | grep $mod
  if [[ "" = "$(puppet module list | grep $mod)" ]]; then
    puppet module install "$mod"
  fi
done
