# My NixOS configuration

This is very much inspired by the following configurations:
+ [Mitchell Hashimoto](https://github.com/mitchellh/nixos-config)
+ [Gabriel Volpe](https://github.com/gvolpe/nix-config)
+ [Henrik Lissner](https://github.com/hlissner/dotfiles)

## Setup
### Create and start the virtual machine
In a terminal window run:

```sh
make vm/create
```

This will create and start the VM.
The default name for the VM is ~devbox~, to use a different name you can provide the name in the
~NIX_NAME~ environment variable:

```sh
NIX_NAME=my-awesome-box make vm/create
```

Wait for the VM to start (this might take a while as it downloads the ISO and boots the installer),
If you want to save some time, you can also give the path to the installer ISO using the environment
variable ~NIX_ISO~:
```sh
NIX_ISO=/tmp/nixos-minimal.iso make vm/create
```

### Change the root password
In the VM, switch to root user: `sudo su` and change the password: `passwd` (the new password must be *root*)

### Install NixOS:
```sh
NIX_IP=xxx.xxx.xxx.xxx make nixos/install
```

You can find out the IP address of the VM either by running `ip a` in the VM, or in your hosts terminal run:
```sh
virsh net-dhcp-leases default | grep nixos | awk '{ print $5 }' | sed 's/\/.\*//'
```

This will end up in an error: `make: *** [Makefile:39: nixos/install] Error 255`
but you can safely ignore it, it's just because the VM is rebooting.

### (optional) Take a snapshot of the VM
At this point you can take a snapshot of the VM if you want, just so you have a good base to return
to in case you mess something up. See: [snapshot management](#snapshot-management)

### Bootstrap the nix configuration

## Snapshot management

### Create snapshot
```sh
virsh shutdown --domain devbox
virsh snapshot-create-as --domain devbox --name "pre-bootstrap"
virsh start devbox
```

replace `devbox` with the name of your VM if you changed it.

### Reverting back to the snapshot
```sh
virsh shutdown --domain VM-NAME
virsh snapshot-revert --domain VM-NAME --snapshotname "pre-bootstrap" --running
```

### Listing snapshots
```sh
virsh snapshot-list VM-NAME
```

### Deleting a snapshot
```sh
virsh snapshot-delete --domain VM-NAME --snapshotname "pre-bootstrap"
```


## Other stuff

### Connecting to a running VM
```sh
virsh --connect qemu:///system console VM-NAME
```

### Configure a static IP to the VM
Find out the MAC address of the VM:
```sh
virsh dumpxml VM-NAME |grep -i '<mac'
```

Edit the default network:

```sh
virsh net-edit default
```

Find the following section:

```xml
<dhcp>
  <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
```

And append the static IP after the range:

```xml
<dhcp>
  <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
  <host mac='XX:XX:XX:XX:XX:XX' name='VM-NAME' ip='xxx.xxx.xxx.xxx' />
```

Restart the DHCP service:

```sh
virsh net-destroy default
virsh net-start default
```

### Deleting everything and starting over
1. Stop the VM with `virsh destroy devbox`
2. Remove the domain with `virsh undefine devbox --nvram` (deletes the VM)
3. Remove the disk image

