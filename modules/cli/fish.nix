{
  flake.modules.homeManager.fish = { pkgs, ... }: {
    programs.fish.enable = true;
    programs.fish.interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
