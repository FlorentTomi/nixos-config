# Dedicated keypair for the Pi (not any one desktop's local ~/.ssh, which
# wouldn't survive a reformat) — private half is sops-encrypted on
# ftomi-nixos, see hosts/ftomi-nixos/secrets.yaml and users.nix.
{
  homeManager.modules.ssh-ftomi-rpi =
    { osConfig, ... }:
    {
      programs.ssh.settings."ftomi-rpi" = {
        hostname = "192.168.1.21"; # update if the Pi's DHCP lease changes
        user = "ftomi";
        identityFile = osConfig.sops.secrets."ssh-key-ftomi-rpi".path;
        identitiesOnly = true;
      };
    };
}
