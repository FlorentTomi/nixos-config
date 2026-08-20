{
  homeManager.modules.matrix =
    { pkgs, ... }:
    {
      programs.element-desktop = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "element-desktop";
          paths = [ pkgs.element-desktop ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/element-desktop \
              --add-flags "--password-store=gnome-libsecret"
          '';
        };
      };
    };
}
