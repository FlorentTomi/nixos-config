{
  flake.modules.homeManager.keyring =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gcr
      ];

      services.gnome-keyring.enable = true;
    };
}
