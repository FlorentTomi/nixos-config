{
  flake.modules.homeManager.keyring =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.proton-pass-cli
        pkgs.gcr
      ];

      services.proton-pass-agent.enable = true;
      services.gnome-keyring.enable = true;

      home.sessionVariables.PROTON_PASS_LINUX_KEYRING = "dbus";

      systemd.user.services.proton-pass-agent = {
        Service.Environment = [ "PROTON_PASS_LINUX_KEYRING=dbus" ];
      };
    };
}
