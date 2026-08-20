{
  nixos.modules.secrets = {
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = false;
  };

  homeManager.modules.secrets =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.sops
        pkgs.age
        pkgs.dashlane-cli
      ];
    };
}
