# vagrant-boxes
Vagrant boxes for my own use.

## `docker-host`

This box is useful if you are forced to use a Windows environment, but need a DevOps environment ready-to-go.
Refer to [this Readme](http://github.com/savishy/vagrant-boxes/tree/master/docker-host/README.md) for details.

## `docker-registry`

This box is useful if you need a ready-to-go Docker Registry to hack against. The registry is accessible from other VMs on the same machine, or from your Windows machine as well.

Refer to [this Readme](http://github.com/savishy/vagrant-boxes/tree/master/docker-registry/README.md) for more details.

## `vagrant-jenkins`

This Vagrant box contains a *fresh instance of Jenkins* on a Linux VM, without any configuration.

[Refer the readme](http://github.com/savishy/vagrant-boxes/tree/master/vagrant-jenkins/README.md) for more information.

## `docker-jenkins`

This box provides Jenkins as a Docker container with Vagrant. The difference from `vagrant-jenkins` is that this box is ready-to-go and more customized to my use (and hence may not be for all audiences).

[See the readme](http://github.com/savishy/vagrant-boxes/tree/master/docker-jenkins/README.md) for more information.
