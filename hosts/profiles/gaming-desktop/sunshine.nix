{ ... }:
{
  # Streams games out of THIS machine (the gaming desktop). Moonlight, the
  # client counterpart, lives in home/profiles/gaming/moonlight.nix instead
  # — a host only ever needs one side of this pair.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = false;
  };
}
