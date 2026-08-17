{
  lib,
  osConfig,
  ...
}:
let
  vpnNames = import ../resources/vpn-names.nix { inherit osConfig; };
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fastfetch
    '';

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

  xdg.configFile."fish/completions/vpn.fish".text = ''
    complete -c vpn -f
    complete -c vpn -n 'test (count (commandline -opc)) = 1' -a '${lib.concatStringsSep " " vpnNames}' -d 'VPN name'
    complete -c vpn -n 'test (count (commandline -opc)) = 2' -a 'on off status start stop' -d 'action'
  '';
}
