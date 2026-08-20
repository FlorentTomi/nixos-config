{
  # Streams games out of this machine. Moonlight (modules/moonlight.nix) is
  # the client counterpart — a host only ever needs one side of this pair.
  nixos.modules.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = false;
    };
  };
}
