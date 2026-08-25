{
  # Wired desktop, no battery to save — favor throughput/latency over
  # power saving (a laptop archetype would want the opposite).
  flake.modules.nixos.wifi-performance = {
    networking.networkmanager.wifi.powersave = false;
  };
}
