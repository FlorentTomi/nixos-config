# Ethernet-only, plain DHCP — no NetworkManager (that's for the desktop's
# GUI/Wi-Fi needs; this box is wired and headless).
_: {
  networking = {
    hostName = "ftomi-rpi";
    useDHCP = true;
    firewall.enable = true;
  };
}
