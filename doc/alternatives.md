# Alternatives to VM

Explorations in portability.


## WSL

Ansible runs under the Windows Subsystem for Linux just fine, it can even talk to Docker-Desktop if you want. It plays great with [VS-Code](https://code.visualstudio.com/docs/remote/wsl).

However there are no CentOS or RHEL distributions available in the MS store. We could [roll our own WSL](https://github.com/Microsoft/WSL-DistroLauncher), but it seems like hard work.

The [lack of systemd](https://github.com/microsoft/WSL/issues/994) can be another annoying thing to code around - like this BASH snippet:

```
      case $MY_HOST_TYPE in
        vagrant)
          echo "[*] start Redis via systemd";
          systemctl start redis-server;
          systemctl enable redis-server;
        ;;
        wsl)
          echo "[*] start Redis via init.d";
          /etc/init.d/redis-server start;
          update-rc.d redis-server enable;
        ;;
      esac
```

Having the same systemd commands work on RHEL/CentOS or Ubuntu/Debian etc was a win for me, and WSL went backwards there. I thought we had depreciated init.d on Linux? Remember for a bit there when Ubuntu had upstart instead, sometimes I don't know what is going on anymore - but environment specific hacks become unwieldy fast (we want nice things, like clean portable code).

But anyway WSL1 is not a real Linux (WSL2 not quite yet), nor can I run WSL1 on one or MacOS (for portability and testing sake - but at some point it gets ridiculous).


## Docker

Containers are sometimes very useful, but I choose not to run Ansible from inside a container (inside the VM Docker is super useful).

On Windows 10 Docker Desktop on runs in a VM under Hyper-V (when Hyper-V is enabled, VirtualBox no longer works). You can run Docker alongside Vagrant, unless you want to use VirtualBox boxes.

I like using Redis to hold the Ansible fact cache, so this means using a multi-container system. Using Docker-Compose is fine, but not all container systems use this - like Podman (sure there are solutions to this like [podman-compose](https://github.com/containers/podman-compose)).

I have tried running different services accross containers for Ansible and it became cumbersome. I also feel that if I need to install systemd or a ssh-server into my containers I have defeated the point in using them.

If you are solely using Ansible, then running it from a container is probably a good option for you - check out [Ansible-silo](https://groupon.github.io/ansible-silo/).


## conclusion

WSL and docker work just fine for running Ansible. But these are not full Linux operating systems, somtimes you want minimalism and other times you need an entire kitchen.
