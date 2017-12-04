# docker-ansible-host

This is a recipe for a Virtualbox Virtual Machine that contains DevOps tools
* puppet
* Ansible
* Docker

along with several useful development tools.

## Prerequisites

* A windows machine. Tested on Windows 7 and 10 (x64)
* Cygwin is recommended.
* Vagrant. Tested with Vagrant 1.8.5.
* Virtualbox. Tested with v5.0+

## How to run

Run this from a terminal:

* Clone the repository
* `cd vagrant-boxes/docker-host`
* `vagrant up`

Bringing up the VM and provisioning it usually takes 10-20 minutes the first time.

## Notes

## What can I do with this Vagrant box?

### Use it as a Docker Server!
* A Docker Daemon listens on port 4243 inside the VM. (See docs on [Docker Remote API](https://docs.docker.com/engine/reference/api/docker_remote_api/)).
* After the machine is up and running, it forwards port 4243 on your *local machine* to port 4243 *inside the VM.*
* This means you can issue REST API commands to this server using any REST Client!

Try this while the VM is running (assuming you have curl on Windows):

`curl -X GET http://localhost:4243/info`

You should see output corresponding to `docker info`. The cool part is you don't need Docker installed on your Windows host machine!

```
{
  "ID": "U3IS:U6EW:2J7G:2URV:RX3R:KRB5:YAWD:WW24:AH5W:BMAM:WZEG:WQSK",
  "Containers": 1,
  "ContainersRunning": 1,
  "ContainersPaused": 0,
  "ContainersStopped": 0,
  "Images": 5,
  "IndexServerAddress": "https://index.docker.io/v1/",
  ...
  ...
  "DockerRootDir": "/var/lib/docker",
  "HttpProxy": "",
  "HttpsProxy": "",
  "NoProxy": "",
  "Name": "ubuntu-14",
  ...
```

**Note when running Dockerized applications inside the box:**

The Vagrant Box forwards only a limited set of ports from the *host* (your machine) to the *VM* (the Vagrant Box).

Say you start a Tomcat container inside the running Vagrant Box:

`docker run -d -it tomcat:7-jre8`

This container would start up fine, but you would need to explicitly publish the port as well in order to be able to access it from *your host* eg from a browser.

`docker run -d -p 8080:8080 -it tomcat:7-jre8`


### Use it as an Ansible Control Machine!

Ansible does not run on Windows. (Not easily any way.)

This VM comes preinstalled with Ansible, so you can provision Ansible hosts easily.

## Troubleshooting

### If you receive any error with VBoxManage, run `vagrant reload`

If you receive an error similar to the following when doing a `vagrant up`:

```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]
VBoxManage.exe: error: Failed to create the host-only adapter
```

Try running a `vagrant reload`.
