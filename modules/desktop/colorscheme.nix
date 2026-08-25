{
  flake.modules.homeManager.colorscheme =
    {
      inputs,
      config,
      pkgs,
      ...
    }:
    let
      p = config.lib.stylix.colors;
      
      themePalette = {
        background = p.base00;
        background-alt = p.base01;
        background-selection = p.base02;
        text = p.base05;
        text-alt = p.base04;
        warning = p.base0A;
        urgent = p.base09;
        error = p.base08;
        accent = p.base0D;
        accent-alt = p.base0E;

        window-manager = {
          window-border-unfocused = p.base03;
          window-border-focused = p.base0D;
          window-border-unfocused-group = p.base03;
          window-border-focused-group = p.base0D;
          window-border-urgent = p.base08;
          text-window-title = p.base05;
        };

        popup = {
          window-border = p.base0D;
          background = p.base00;
          text = p.base05;
          border-high-urgency = p.base08;
          border-low-urgency = p.base03;
          progressbar-incomplete = p.base01;
          progressbar-complete = p.base02;
        };

        dark = {
          text = p.base00;
          text-alt = p.base01;
          background-item-on = p.base0E;
          background-item-off = p.base0D;
          background-item-on-alt = p.base09;
          background-item-off-alt = p.base02;
          background-list-unselected = p.base0D;
          background-list-selected = p.base03;
        };

        image = {
          background = p.base00;
          background-alt = p.base01;
          main = p.base05;
          main-alt = p.base04;
          red = p.base08;
          orange = p.base09;
          yellow = p.base0A;
          green = p.base0B;
          cyan = p.base0C;
          blue = p.base0D;
          purple = p.base0E;
          brown = p.base0F;
        };
      };
    in
    {
      imports = [ inputs.stylix.homeModules.stylix ];

      stylix.enable = true;
      stylix.autoEnable = true;
      stylix.polarity = "dark";
      
      stylix.targets.starship.enable = false;
      
      stylix.fonts = {
        serif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };

        emoji = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
      };

      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

      _module.args = {
        inherit themePalette;
      };
    };
}
