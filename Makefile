VM_NAME ?= devbox
VM_IP ?= unset
VM_DISK_IMAGE ?= /data/libvirt/$(VM_NAME).qcow2
VM_DISK_SIZE ?= 40
VM_CPUS ?= 4
VM_MEMORY ?= 8196
# The block device prefix to use.
#   - sda for SATA/IDE
#   - vda for virtio
VM_BLOCK_DEVICE ?= vda

NIX_USER ?= tuomo

NIX_ISO ?= https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Creates a new VM and boots to the latest NixOS minimal install ISO.
vm/create:
	virt-install --name $(VM_NAME) \
		--memory=$(VM_MEMORY) \
		--vcpus=$(VM_CPUS) \
		--disk path=$(VM_DISK_IMAGE),device=disk,bus=virtio,size=$(VM_DISK_SIZE) \
		--cdrom $(NIX_ISO) \
		--osinfo detect=on,require=on \
		--network network=default \
		--boot=uefi
		# --nographics \
		# --console pty,target_type=virtio

# Install NixOS on a brand new VM. The VM should have NixOS minimal ISO in the CD drive
# and just set the password of the root user to "root". This will install NixOS.
# After installing NixOS, you must reboot and set the root password for the next step.
nixos/install:
	ssh $(SSH_OPTIONS) root@$(NIXADDR) " \
		parted /dev/$(VM_BLOCK_DEVICE) -- mklabel gpt; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(VM_BLOCK_DEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(VM_BLOCK_DEVICE)1; \
		mkswap -L swap /dev/$(VM_BLOCK_DEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(VM_BLOCK_DEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a\\\n\
  nix.package = pkgs.nixUnstable;\n\
  nix.extraOptions = \"experimental-features = nix-command flakes\";\n\
  services.openssh.enable = true;\n\
  services.openssh.passwordAuthentication = true;\n\
  services.openssh.permitRootLogin = \"yes\";\n\
  users.users.root.initialPassword = \"root\";\n\
		' /mnt/etc/nixos/configuration.nix;\
		nixos-install --no-root-passwd; \
		reboot; \
	"

# After nixos/install, run this to finalize. After this, do everything else
# in the VM unless secrets change.
nixos/bootstrap:
	NIX_USER=root $(MAKE) nixos/copy
	NIX_USER=root $(MAKE) nixos/switch
	ssh $(SSH_OPTIONS) root@$(NIXADDR) " \
		reboot; \
	"

# Copy our secrets into the VM
nixos/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIX_USER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIX_USER)@$(NIXADDR):~/.ssh

# Copy the Nix configurations into the VM.
nixos/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.git/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIX_USER)@$(NIXADDR):/etc/nixos

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
nixos/switch:
	ssh $(SSH_OPTIONS) $(NIX_USER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch \
	"

# Build an ISO image
iso/nixos.iso:
	cd iso; ./build.sh
