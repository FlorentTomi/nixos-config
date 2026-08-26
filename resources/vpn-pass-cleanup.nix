{ pkgs }:
# Wipes the runtime-fetched VPN secrets after disconnect. tmpfs-backed, so
# this is more about not leaving decrypted material sitting around between
# uses than an actual disk-remnant concern.
pkgs.writeShellApplication {
  name = "vpn-pass-cleanup";
  text = ''
    name="$1"
    dir=/run/openvpn-secrets
    shred -u "$dir/$name" "$dir/$name-auth" 2>/dev/null || true
  '';
}
