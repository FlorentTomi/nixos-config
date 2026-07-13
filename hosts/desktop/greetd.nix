{ ... }:
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
      default_session = {
        command = ''dbus-run-session niri --config ${./greetd/niri.kdl}'';
        user = "greeter";
      };
    };
  };

  environment.etc."greetd/niri.kdl".source = ./greetd/niri.kdl;
}
