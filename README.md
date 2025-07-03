# inception

With this project, we students of 42 School will learn system administration through the implementation of a small infrastructure composed of different services with docker.

## Docker

It is hard to explain docker without explaining virtualization. 
Basically, virtualization enables virtual representations physical machines, like computers. A person can resort to virtualization for many motives, which you can search for yourself, but the the point is that people usually used software like [vmware](https://https://www.vmware.com/), [virtualbox](https://www.virtualbox.org/) or [parallels](https://www.parallels.com/) for mac.
In the professional world, people found that is kind of unnecessary to fun a full operating system just to run a service in the background.
Docker is a technology that eliminates this redundancy by running softwares in containers that has its own software environment but shares the operating system and physical resources of the host machine (such as CPU, memory, and disk), so, kinda like a VM, but not.

It was asked to make this project in a VM, preferably, in the latest version of Alpine or Debian because they are relatively small, secure and stable distros.