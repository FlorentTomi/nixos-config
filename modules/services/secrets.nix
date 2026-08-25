{
  flake.modules.nixos.secrets = {
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = false;
  };

  flake.modules.homeManager.secrets =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.sops
        pkgs.age
        pkgs.dashlane-cli
      ];
    };
}
