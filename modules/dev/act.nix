{
  flake.modules.nixos.act =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.act
      ];
    };
}
