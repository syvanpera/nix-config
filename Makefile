NIX_NAME ?= devbox
NIX_USER ?= tuomo

NIX_ISO ?= https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
# NIX_ISO ?= ~/Downloads/images/nixos-minimal-23.05.4112.5a237aecb572-x86_64-linux.iso

PROTOCOL_HTTPS ?= https://github.com/
PROTOCOL_GIT ?= git@github.com:

NIX_CONF_REPO_PROTOCOL ?= $(PROTOCOL_HTTPS)
NIX_CONF_REPO ?= syvanpera/nix-config.git
NIX_CONF_REPO_BRANCH ?= main
NIX_CONF_DIR ?= /etc/nix-config

VM_IP ?= unset
VM_DISK_IMAGE ?= /data/libvirt/images/$(NIX_NAME).qcow2
VM_DISK_SIZE ?= 50
VM_CPUS ?= 4
VM_MEMORY ?= 8196
# The block device prefix to use.
#   - sda for SATA/IDE
#   - vda for virtio
VM_BLOCK_DEVICE ?= vda

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Downloads the latest NixOS minimal install ISO.
nixos/download:
	wget $(NIX_ISO)

# Creates a new VM and boots to the latest NixOS minimal install ISO.
vm/create:
	virt-install --name $(NIX_NAME) \
		--memory=$(VM_MEMORY) \
		--vcpus=$(VM_CPUS) \
		--video qxl,vgamem=65536 \
		--disk path=$(VM_DISK_IMAGE),device=disk,bus=virtio,size=$(VM_DISK_SIZE) \
		--cdrom latest-nixos-minimal-x86_64-linux.iso \
		--osinfo detect=on,require=on \
		--network network=default \
		--boot=uefi
		# --nographics \
		# --console pty,target_type=virtio

vm/ip:
	@virsh net-dhcp-leases default | grep nixos

# Install NixOS on a brand new VM. The VM should have NixOS minimal ISO in the CD drive
# and just set the password of the root user to "root". This will install NixOS.
# After installing NixOS, you must reboot and set the root password for the next step.
nixos/install:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
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
  environment.systemPackages = [ pkgs.git ];\n\
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
	NIX_USER=root $(MAKE) nixos/clone
	$(MAKE) nixos/switch
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		reboot; \
	"

nixos/usersetup:
	$(MAKE) nixos/secrets
	NIX_CONF_DIR=/home/$(NIX_USER)/nix-config NIX_CONF_REPO_PROTOCOL=$(PROTOCOL_GIT) $(MAKE) nixos/clone
	ssh $(SSH_OPTIONS) $(NIX_USER)@$(VM_IP) " \
		cd /home/$(NIX_USER)/nix-config; \
		nix build .#homeConfigurations.$(NIX_USER).activationPackage; \
		./result/activate; \
	"
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		reboot; \
	"

# Checkout my Nix configurations repo into the VM.
nixos/clone:
	ssh $(SSH_OPTIONS) $(NIX_USER)@$(VM_IP) " \
		git clone --branch $(NIX_CONF_REPO_BRANCH) $(NIX_CONF_REPO_PROTOCOL)$(NIX_CONF_REPO) $(NIX_CONF_DIR); \
		cp /etc/nixos/hardware-configuration.nix $(NIX_CONF_DIR)/system/$(NIX_NAME); \
	"

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run nixos/clone before.
nixos/switch:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		cd $(NIX_CONF_DIR) && nixos-rebuild switch --flake .#$(NIX_NAME) \
	"

# Copy secrets from the host into the VM
nixos/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIX_USER)@$(VM_IP):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIX_USER)@$(VM_IP):~/.ssh

# Build an ISO image
iso/nixos.iso:
	cd iso; ./build.sh
