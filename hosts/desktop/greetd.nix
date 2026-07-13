{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
      user = "greeter";
    };
  };

  environment.etc."greetd/regreet.toml".source = ./greetd/regreet.toml;
}
