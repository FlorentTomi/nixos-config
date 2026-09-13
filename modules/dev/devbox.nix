{
  flake.modules.homeManager.devbox = { pkgs, ... }: {
    home.packages = [
      pkgs.devbox
    ];
  };
}
