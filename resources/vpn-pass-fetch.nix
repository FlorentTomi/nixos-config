{ pkgs }:
# Pulls a VPN's OpenVPN profile (Proton Pass note item "<name>", vault "VPN") and,
# if present, its auth pair (login item "<name>-auth") into
# /run/openvpn-secrets/ right before the matching systemd unit starts —
# replaces the old sops-managed always-decrypted files. Assumes every
# currently-configured VPN has hasAuth = true; if a no-auth VPN is added,
# the auth fetch below will just fail loudly, which is a signal to revisit
# this script rather than a silent gap.
pkgs.writeShellApplication {
  name = "vpn-pass-fetch";
  runtimeInputs = [
    pkgs.proton-pass-cli
    pkgs.coreutils
  ];
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
}
