# This host's home-manager profiles (home/${user}/ identity is always
# imported separately by lib/mk-host.nix). Add/remove a line to change what
# this host's home-manager config gets — no string-list indirection.
{ ... }:
{
  imports = [
    ../../home/profiles/shell
    ../../home/profiles/dual-monitor.nix
    ../../home/profiles/waybar.nix
    ../../home/profiles/fuzzel.nix
    ../../home/profiles/walker.nix
    ../../home/profiles/hyprlock.nix
    ../../home/profiles/wleave.nix
    ../../home/profiles/session
    ../../home/profiles/yazi.nix
    ../../home/profiles/gaming
    ../../home/profiles/hobbies
    ../../home/profiles/pasystray.nix
    ../../home/profiles/work.nix
    ../../home/profiles/eww.nix
  ];
}
