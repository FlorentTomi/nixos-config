{
  flake.modules.homeManager.nix-lang-tooling =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nil
        pkgs.nixd
      ];
    };
}
