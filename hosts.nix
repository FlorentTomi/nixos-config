# Host definitions, fed to lib/mk-host.nix and lib/mk-home.nix. One attrset
# per host, producing one nixosConfiguration and one matching
# homeConfiguration (keyed "<user>@<hostname>", the default `nh home
# switch` looks for) — so home-manager changes can be switched on their
# own without a full `nh os switch`.
#
# `homeProfiles` (opt-in extras) are the same list either way; `home/${user}`
# (identity: always-on regardless of host) is imported unconditionally by
# both mk-host.nix and mk-home.nix.
{ mkHost, mkHome }:
let
  hosts = {
    ftomi-nixos = {
      hostname = "ftomi-nixos";
      user = "ftomi";
      homeProfiles = [
        "shell"
        "dual-monitor"
        "waybar"
        "walker"
        "lock"
        "powermenu"
        "session"
        "yazi"
        "gaming"
        "hobbies"
        # "ollama"
        "audio"
        "work"
      ];
      diskDevice = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H801497R";
    };
  };
in
{
  nixosConfigurations = builtins.mapAttrs (_: mkHost) hosts;
  homeConfigurations = builtins.listToAttrs (
    map (h: {
      name = "${h.user}@${h.hostname}";
      value = mkHome h;
    }) (builtins.attrValues hosts)
  );
}
