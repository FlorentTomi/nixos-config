{ pkgs }:
# Single source of truth for starting/stopping a VPN: fetches secrets from
# Proton Pass (vpn-pass-fetch) before start, wipes them (vpn-pass-cleanup)
# after stop — the systemd unit's config file lives in the not-yet-populated
# /run/openvpn-secrets/ otherwise. Shared by the `vpn` fish function
# (pytheas.nix) and the walker/elephant vpn menu (walker.nix) so this
# fetch/cleanup dance only needs to be gotten right once.
let
  vpnPassFetch = pkgs.writeShellApplication {
    name = "vpn-pass-fetch";
    runtimeInputs = [
      pkgs.proton-pass-cli
      pkgs.coreutils
    ];
    # Pulls a VPN's OpenVPN profile (Proton Pass note item "<name>", vault "VPN") and,
    # if present, its auth pair (login item "<name>-auth") into
    # /run/openvpn-secrets/ right before the matching systemd unit starts —
    # replaces the old sops-managed always-decrypted files. Assumes every
    # currently-configured VPN has hasAuth = true; if a no-auth VPN is added,
    # the auth fetch below will just fail loudly, which is a signal to revisit
    # this script rather than a silent gap.
    text = ''
      name="$1"
      dir=/run/openvpn-secrets
      umask 077

      pass-cli item view --vault-name "VPN" --item-title "$name" \
        --field note > "$dir/$name"

      pass-cli item view --vault-name "VPN" --item-title "$name-auth" \
        --field username > "$dir/$name-auth"
      pass-cli item view --vault-name "VPN" --item-title "$name-auth" \
        --field password >> "$dir/$name-auth"
    '';
  };

  vpnPassCleanup = pkgs.writeShellApplication {
    name = "vpn-pass-cleanup";
    # Wipes the runtime-fetched VPN secrets after disconnect. tmpfs-backed, so
    # this is more about not leaving decrypted material sitting around between
    # uses than an actual disk-remnant concern.
    text = ''
      name="$1"
      dir=/run/openvpn-secrets
      shred -u "$dir/$name" "$dir/$name-auth" 2>/dev/null || true
    '';
  };
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
