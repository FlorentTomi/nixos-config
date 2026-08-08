{ lib, pkgs, vpnNames }:
# Shared backend: no-arg call lists VPNs with their state (used by both
# rofi's script-mode and dmenu-style pickers). Called again with a selected
# "name (on|off)" line as $1, it toggles that VPN's systemd unit, then
# (like rofi script-mode expects) prints the refreshed list.
pkgs.writeShellApplication {
  name = "vpn-select";
  runtimeInputs = [ pkgs.systemd ];
  text = ''
    vpns=(${lib.concatStringsSep " " vpnNames})

    if [[ -n "''${1-}" ]]; then
      name="''${1%% *}"
      if systemctl is-active --quiet "openvpn-$name"; then
        systemctl stop "openvpn-$name"
      else
        systemctl start "openvpn-$name"
      fi
    fi

    for name in "''${vpns[@]}"; do
      if systemctl is-active --quiet "openvpn-$name"; then
        echo "$name 󰌾 on"
      else
        echo "$name 󰌿 off"
      fi
    done
  '';
}
