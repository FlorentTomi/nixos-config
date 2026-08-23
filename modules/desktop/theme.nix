{
  homeManager.modules.theme =
    {
      pkgs,
      themePalette,
      ...
    }:
    {
      wayland.windowManager.niri.settings.layout.border = {
        active-color = "#${themePalette.window-manager.window-border-focused}";
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

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple";
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
          monospace = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "JetBrainsMono Nerd Font" ];
          serif = [ "JetBrainsMono Nerd Font" ];
        };
      };

      programs.starship.presets = [ "catppuccin-powerline" ];
      programs.starship.settings.palette = "catppuccin_mocha";

      home.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
