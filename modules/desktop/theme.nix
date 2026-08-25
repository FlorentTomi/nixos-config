{
  homeManager.modules.theme =
    {
      pkgs,
      themePalette,
      ...
    }:
    {
      wayland.windowManager.niri.settings.layout.border = {
        active-color = "#${themePalette.accent}";
        inactive-color = "#${themePalette.window-manager.window-border-unfocused}";
      };

      gtk = {
        enable = true;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
      };

      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
      };

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
          sansSerif = [ "JetBrainsMono Nerd Font Mono" ];
          serif = [ "JetBrainsMono Nerd Font Mono" ];
        };
      };

      programs.starship.presets = [ "catppuccin-powerline" ];
      programs.starship.settings.palette = "catppuccin_mocha";

      home.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
