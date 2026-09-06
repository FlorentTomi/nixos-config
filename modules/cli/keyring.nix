{
  flake.modules.homeManager.keyring =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gcr
      ];
    };
}
