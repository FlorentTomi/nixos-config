{
  flake.modules.homeManager.proton =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.proton-authenticator
        pkgs.proton-pass
        pkgs.proton-pass-cli
      ];

      services.proton-pass-agent.enable = true;

      home.sessionVariables.PROTON_PASS_LINUX_KEYRING = "dbus";

      systemd.user.services.proton-pass-agent = {
        Service.Environment = [ "PROTON_PASS_LINUX_KEYRING=dbus" ];
      };
    };
}
