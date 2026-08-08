{ config, lib, pkgs, ... }:
let
  cfg = config.modules.niri;
in
{
  # No `imports` needed: programs.niri is nixpkgs' own native NixOS module
  # (nixos/modules/programs/wayland/niri.nix, co-maintained by niri-flake's
  # own author) and is already part of the module list nixpkgs provides.
  # We used to import inputs.niri.nixosModules.niri here; niri-flake's
  # module actively disabled the nixpkgs one to avoid the two conflicting,
  # so dropping the import just lets the native one take over.
  options.modules.niri.enable = lib.mkEnableOption "niri window manager";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    # The native module already sets a sensible xdg.portal.config.niri
    # (Access/Notification -> gtk, Secret -> gnome-keyring) unconditionally,
    # so most of this merges in for free. Its own `default` is
    # ["gnome" "gtk"], which conflicts with ours below (two non-default
    # definitions of the same leaf is a hard eval error) — we override with
    # mkForce specifically because screen-sharing on this host goes through
    # xdg-desktop-portal-wlr (see hosts/base/portals.nix), not gnome/gtk,
    # and neither of those actually implements ScreenCast for a wlroots
    # compositor. Every other key from the native module's config.niri
    # (Access, Notification, Secret) is untouched here and still applies.
    xdg.portal.config.niri = {
      default = lib.mkForce [
        "gnome"
        "wlr"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };

    # The one thing the native module doesn't provide that niri-flake's did:
    # a running polkit authentication agent. Without this, GUI apps that
    # need privilege escalation (NetworkManager applet, disk-mounting
    # tools, etc.) have no way to actually prompt for a password.
    security.polkit.enable = true;
    systemd.user.services.niri-polkit-agent = {
      description = "PolicyKit Authentication Agent (polkit-kde-agent)";
      wantedBy = [ "niri.service" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
