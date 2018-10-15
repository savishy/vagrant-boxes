# `vagrant-jenkins`

This Vagrant box provides a clean installation of Jenkins 2.x on Ubuntu 16.04 LTS.

## How to use

```
git clone http://github.com/savishy/vagrant-boxes
cd vagrant-jenkins
vagrant up
```

## What does this box provide?

This box provides a clean installation of Jenkins, with nothing apart from the default plugins.

Contrast this with the box `docker-jenkins`, which provisions Jenkins, bypasses initial admin authentication, installs plugins etc.

This is useful for some situations such as

* Demos where a clean-slate is needed;
* Situations where extensive customization is required
