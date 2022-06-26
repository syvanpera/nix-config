# My NixOS configuration

This is very much inspired by (at least) the following configurations:
+ [Mitchell Hashimoto](https://github.com/mitchellh/nixos-config)
+ [Gabriel Volpe](https://github.com/gvolpe/nix-config)
+ [Henrik Lissner](https://github.com/hlissner/dotfiles)

- Apply system:
  ```sh
  sudo nixos-rebuild switch --flake .#
  ```
- Apply Home Manager:
  ```sh
  home-manager switch --flake .#tuomo
  ```
  or
  ```sh
  nix build --flake .#homeConfigurations.tuomo.activationPackage
  ./result/activate
  ```

## Setup

1. Create and start the virtual machine
   In a terminal window run:

   ```sh
   make vm/create
   ```

   This will create and start the VM.
   The default name for the VM is `devbox`, to use a different name you can
   provide the name in the `NIX_NAME` environment variable:

   ```sh
   NIX_NAME=my-awesome-box make vm/create
   ```

   Wait for the VM to start (this might take a while as it downloads the ISO
   and boots the installer). If you want to save some time, you can also give
   the path to the installer ISO using the environment variable `NIX_ISO`:
   ```sh
   NIX_ISO=/tmp/nixos-minimal.iso make vm/create
   ```

2. Change the root password
   In the VM, switch to root user: `sudo su` and change the password: `passwd`
   (the new password must be *root*)

3. Install NixOS
   ```sh
   NIX_IP=xxx.xxx.xxx.xxx make nixos/install
   ```

   You can find out the IP address of the VM either by running `ip a` in the VM
   or from your hosts terminal by running:
   ```sh
   virsh net-dhcp-leases default | grep nixos | awk '{ print $5 }' | sed 's/\/.\*//'
   ```

   This will end up in an error:
   `make: *** [Makefile:39: nixos/install] Error 255`
   but you can safely ignore this, it's just because the VM is rebooting.

4. Take a snapshot of the VM (optional)
   At this point you can take a snapshot of the VM if you want, just so you
   have a good base to return to in case you mess something up.
   See: [snapshot management](#snapshot-management)

5. Bootstrap the nix configuration
   ```sh
   make nixos/bootstrap
   ```

   This will by default create a user `tuomo`, but if you want to change that,
   you can provide the username in the environment variable `NIX_USER`:
   ```sh
   NIX_USER=johndoe make nixos/bootstrap
   ```

6. Change your user's password
   Login as the normal user (password is `password`) and change the password to
   whatever you want.

   You might also want to change the root password and disable ssh for root.

7. Enjoy!

## Snapshot management

+ Create snapshot
  ```sh
  virsh shutdown --domain devbox
  virsh snapshot-create-as --domain devbox --name "pre-bootstrap"
  virsh start devbox
  ```

  replace `devbox` with the name of your VM if you changed it.

+ Reverting back to the snapshot
  ```sh
  virsh shutdown --domain devbox
  virsh snapshot-revert --domain devbox --snapshotname "pre-bootstrap" --running
  ```

+ Listing snapshots
  ```sh
  virsh snapshot-list devbox
  ```

+ Deleting a snapshot
  ```sh
  virsh snapshot-delete --domain devbox --snapshotname "pre-bootstrap"
  ```

## Other stuff

### Configure a static IP to the VM

1. Find out the MAC address of the VM:
   ```sh
   virsh dumpxml devbox |grep -i '<mac'
   ```

2. Edit the default network:
   ```sh
   virsh net-edit default
   ```

3. Find the following section:
   ```xml
   <dhcp>
     <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
   ```

   And append the static IP after the range:
   ```xml
   <dhcp>
     <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
     <host mac='XX:XX:XX:XX:XX:XX' name='devbox' ip='xxx.xxx.xxx.xxx' />
   ```

4. Restart the DHCP service:
   ```sh
   virsh net-destroy default
   virsh net-start default
   ```

### Connecting to a running VM

```sh
virsh --connect qemu:///system console devbox
```

### Deleting everything and starting over

1. Stop the VM with `virsh destroy devbox`
2. Remove the domain with `virsh undefine devbox --nvram` (deletes the VM)
3. Remove the disk image
