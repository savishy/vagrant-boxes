# Windows Vagrant Boxes

This directory contains Windows Vagrant boxes. Most boxes are created with `virtualbox` driver, but I am starting to create some boxes with the `hyperv` driver as well.

## Note on Windows and Hyper-V

If you are *starting fresh* on Windows + Hyper-V boxes, you may encounter network problems. This is because of fundamental issues with the way Vagrant communicates with Hyper-V.

To make these Windows Vagrant boxes work you **have** to follow the instructions below to setup network:
[https://gist.github.com/savishy/8ed40cd8692e295d64f45e299c2b83c9](https://gist.github.com/savishy/8ed40cd8692e295d64f45e299c2b83c9)
