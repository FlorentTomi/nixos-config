{
  flake.modules.nixos.vm-curator =
    { inputs, pkgs, ... }:
    {
      environment.systemPackages = [ inputs.vm-curator.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
