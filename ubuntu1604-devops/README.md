# Ubuntu 16.04 + DevOps

This Vagrant box provides basic devops tools and an Ubuntu environment to manage them.

I created this box in order to provide myself a consistent environment across different Operating Systems.

## Operating System

I use [`geerlingguy/ubuntu1604`](https://atlas.hashicorp.com/geerlingguy/boxes/ubuntu1604/). I decided to go with this after facing multiple issues with the Canonical boxes.

## Tools

DevOps:

* Docker Engine
* Ansible

Other:


## How to use

* Install Vagrant.
* Clone this repository and `cd` to this folder.
* Run `vagrant up`.
* After the machine comes up, `vagrant ssh` to use it.

**Note:** On a first-time run, this will take some time as it needs to download everything afresh.

**Note:** Most DevOps tools will never require you to have the Ubuntu GUI. Therefore this box does not provide a GUI.

## Provisioning with Puppet

* I also got acquainted with Puppet while writing the `Vagrantfile`.
* This is a good example of master-less provisioning with Puppet.

## Notes

This repository uses the following Puppet Modules:

* [`garethr-docker`](https://forge.puppet.com/garethr/docker) for installing Docker
* [`nvogel-ansible`](https://forge.puppet.com/nvogel/ansible/1.1.1) for installing Ansible
