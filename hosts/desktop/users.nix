{ pkgs, ... }:
{
  users.users.ftomi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
