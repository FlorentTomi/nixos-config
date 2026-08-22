# Ethernet-only, plain DHCP — no NetworkManager (that's for the desktop's
# GUI/Wi-Fi needs; this box is wired and headless).
{ ... }:
{
  networking.hostName = "ftomi-rpi";
  networking.useDHCP = true;
  networking.firewall.enable = true;
}
