{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "fi";
    xkbVariant = "nodeadkeys";
    xkbOptions = "caps:ctrl_modifier";
  };

  # Enable the window manager
  services.xserver.windowManager.i3.enable = true;

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
    git
    wget
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

