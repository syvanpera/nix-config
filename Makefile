NIXNAME ?= devbox

# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= tuomo

NIXISO ?= https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

VM_DISK_IMAGE ?= /data/libvirt/$(NIXNAME).qcow2
VM_DISK_SIZE ?= 40
VM_CPUS ?= 4
VM_MEMORY ?= 8196

VM_DISK_DEVICE ?= vda

# The block device prefix to use.
#   - sda for SATA/IDE
#   - vda for virtio
NIXBLOCKDEVICE ?= vda

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

vm/create:
	virt-install --name $(NIXNAME) \
		--memory=$(VM_MEMORY) \
		--vcpus=$(VM_CPUS) \
		--disk path=$(VM_DISK_IMAGE),device=disk,bus=virtio,size=$(VM_DISK_SIZE) \
		--cdrom $(NIXISO) \
		--osinfo detect=on,require=on \
		--network network=default \
		--boot=uefi
		# --nographics \
		# --console pty,target_type=virtio

# Install the base NixOS system
nixos/install:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/$(NIXBLOCKDEVICE) -- mklabel gpt; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(NIXBLOCKDEVICE)1; \
		mkswap -L swap /dev/$(NIXBLOCKDEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(NIXBLOCKDEVICE)3; \
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

# Start the actual Nix setup
nixos/bootstrap:
	NIXUSER=root $(MAKE) nixos/copy
	# NIXUSER=root $(MAKE) nixos/switch
	# $(MAKE) nixos/secrets
	# ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
	# 	sudo reboot; \
	# "

# Copy secrets into the VM
nixos/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# Copy the Nix configurations into the VM
nixos/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
nixos/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"
