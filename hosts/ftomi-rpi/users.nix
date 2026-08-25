# Key-based auth only via a dedicated keypair (not tied to any one
# desktop's local ~/.ssh, which wouldn't survive a reformat) — private half
# is sops-encrypted in hosts/ftomi-nixos/secrets.yaml as
# "ssh-key-ftomi-rpi", decrypted on whatever desktop needs it.
# initialPassword still exists on the account (impermanence regenerates it
# every boot regardless of any interactive `passwd` change anyway — see
# filesystems.nix, /etc/shadow isn't persisted) but SSH password auth is
# disabled below, so it's only relevant for local console login.
{ pkgs, ... }:
{
  users.users.ftomi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0iGQs2LrOW5nkLH7NJ3kMk0MYQ5IRmyzVEhVa4O1P3 ftomi-rpi-access"
    ];
  };

  programs.fish.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Lets `nixos-rebuild switch --target-host` from the desktop copy
  # locally-built (binfmt cross-compiled) store paths in without needing
  # --option require-sigs false every time.
  nix.settings.trusted-users = [ "ftomi" ];
}
