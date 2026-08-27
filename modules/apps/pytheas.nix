{
  flake.modules.homeManager.pytheas =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      vpnNames = import ../../lib/vpn-names.nix { inherit osConfig; };
      vpnToggle = import ../../lib/vpn-toggle.nix { inherit pkgs; };
    in
    {
      home.packages = [
        vpnToggle
      ];

      programs.fish = {
        functions.vpn = ''
          set -l name $argv[1]
          set -l action $argv[2]

          switch $action
            case on start
              vpn-toggle $name start
            case off stop
              vpn-toggle $name stop
            case status
              systemctl status openvpn-$name --no-pager
            case '*'
              echo "usage: vpn <name> <on|off|status>"
          end
        '';
      };

      xdg.configFile."fish/completions/vpn.fish".text = ''
        complete -c vpn -f
        complete -c vpn -n 'test (count (commandline -opc)) = 1' -a '${lib.concatStringsSep " " vpnNames}' -d 'VPN name'
        complete -c vpn -n 'test (count (commandline -opc)) = 2' -a 'on off status start stop' -d 'action'
      '';

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings."*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };

        settings."git.pytheasnavigation.com" = { };
      };

      programs.git.includes = [
        {
          condition = "hasconfig:remote.*.url:**pytheasnavigation.com**";
          contents.user = {
            name = "Florent TOMI";
            email = "florent.tomi@pytheasnavigation.com";
          };
        }
      ];
    };
}
