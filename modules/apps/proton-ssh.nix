{
  flake.modules.homeManager.proton-ssh =
    { pkgs, ... }:
    {
      systemd.user.services.proton-pass-ssh-agent = {
        Unit.Description = "Proton Pass SSH Agent";
        Service = {
          ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --create-new-identities SSH";
          Restart = "on-failure";
        };

        Install.WantedBy = [ "default.target" ];
      };

      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    };
}
