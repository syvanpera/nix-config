{ config, lib, pkgs, ... }:
let
  mkSure = lib.mkOverride 0;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Make things work in QEMU VM
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = mkSure true;

  nixpkgs.config.allowUnfree = true;

  #virtualisation.qemu.options = [ "-vga qxl" ];
  #virtualisation.memorySize = 8192;
  #virtualisation.cores = 4;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "devbox";

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.utf8";
    LC_IDENTIFICATION = "fi_FI.utf8";
    LC_MEASUREMENT = "fi_FI.utf8";
    LC_MONETARY = "fi_FI.utf8";
    LC_NAME = "fi_FI.utf8";
    LC_NUMERIC = "fi_FI.utf8";
    LC_PAPER = "fi_FI.utf8";
    LC_TELEPHONE = "fi_FI.utf8";
    LC_TIME = "fi_FI.utf8";
  };

  console.useXkbConfig = true;

  # Configure X11
  services.xserver = {
    enable = true;

    layout = "fi";
    xkbVariant = "nodeadkeys";
    xkbOptions = "caps:ctrl_modifier";

    #videoDrivers = [ "qxl" ];

    desktopManager = {
      wallpaper.mode = "fill";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;

    displayManager.defaultSession = "xfce+i3";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tuomo = {
    description = "Tuomo Syvänperä";
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ];
  };

  users.users.root.initialPassword = "root";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    #xorg.xf86videoqxl
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    permitRootLogin = "yes";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

