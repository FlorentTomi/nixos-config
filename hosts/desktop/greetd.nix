{ pkgs, config, ... }:
{
  programs.regreet = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    cursorTheme.name = "Bibata-Modern-Classic";
    settings = {
      skip_selection = false;
    };
  };

  services.greetd.settings.default_session = {
    command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.niri}/bin/niri --config /etc/greetd/niri.kdl";
    user = "greeter";
  };

  environment.systemPackages = [ config.programs.regreet.package ];
  environment.etc."greetd/niri.kdl".source = ./greetd/niri.kdl;
}
