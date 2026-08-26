{
  # Everything needed to work in Pytheas repos on this host: the SSH key for
  # GitLab, and an automatic git identity swap for any repo whose remote
  # points at pytheasnavigation.com — so committing there always uses the
  # work name/email regardless of where the repo lives on disk, with no
  # manual switching required.
  flake.modules.homeManager.work =
    { lib, osConfig, ... }:
    let
      vpnNames = import ../../resources/vpn-names.nix { inherit osConfig; };
    in
    {
      programs = {
        fish = {
          functions.vpn = ''
            set -l name $argv[1]
            set -l action $argv[2]

            switch $action
              case on start
                systemctl start openvpn-$name
              case off stop
                systemctl stop openvpn-$name
              case status
                systemctl status openvpn-$name --no-pager
              case '*'
                echo "usage: vpn <n> <on|off|status>"
            end
          '';
        };

        ssh = {
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
        };

        git.includes = [
          {
            condition = "hasconfig:remote.*.url:**pytheasnavigation.com**";
            contents.user = {
              name = "Florent TOMI";
              email = "florent.tomi@pytheasnavigation.com";
            };
          }
        ];
      };

      xdg.configFile."fish/completions/vpn.fish".text = ''
        complete -c vpn -f
        complete -c vpn -n 'test (count (commandline -opc)) = 1' -a '${lib.concatStringsSep " " vpnNames}' -d 'VPN name'
        complete -c vpn -n 'test (count (commandline -opc)) = 2' -a 'on off status start stop' -d 'action'
      '';
    };
}
