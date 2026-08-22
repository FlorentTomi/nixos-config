# initialPassword is a first-boot bootstrap only — change it after logging
# in once, and switch to key-based auth in users.users.ftomi.openssh.authorizedKeys.keys
# when a public key is available.
{ pkgs, ... }:
{
  users.users.ftomi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
    initialPassword = "changeme";
  };

  programs.fish.enable = true;
  services.openssh.enable = true;
}
