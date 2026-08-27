{ pkgs }:
# Single source of truth for starting/stopping a VPN: fetches secrets from
# Proton Pass (vpn-pass-fetch) before start, wipes them (vpn-pass-cleanup)
# after stop — the systemd unit's config file lives in the not-yet-populated
# /run/openvpn-secrets/ otherwise. Shared by the `vpn` fish function
# (pytheas.nix) and the walker/elephant vpn menu (vpn-menu.nix) so this
# fetch/cleanup dance only needs to be gotten right once.
let
  vpnPassFetch = import ./vpn-pass-fetch.nix { inherit pkgs; };
  vpnPassCleanup = import ./vpn-pass-cleanup.nix { inherit pkgs; };
in
pkgs.writeShellApplication {
  name = "vpn-toggle";
  runtimeInputs = [ pkgs.systemd ];
  text = ''
    name="$1"
    action="$2"

    case "$action" in
      start)
        ${vpnPassFetch}/bin/vpn-pass-fetch "$name"
        systemctl start "openvpn-$name"
        ;;
      stop)
        systemctl stop "openvpn-$name"
        ${vpnPassCleanup}/bin/vpn-pass-cleanup "$name"
        ;;
      *)
        echo "usage: vpn-toggle <name> start|stop" >&2
        exit 1
        ;;
    esac
  '';
}
