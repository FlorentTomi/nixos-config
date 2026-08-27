{ lib, pkgs, vpnNames }:
# elephant menu definition (~/.config/elephant/menus/vpn.lua): lists VPNs
# with live on/off state and toggles the matching openvpn-<name> unit on
# select, via vpn-toggle.nix (same start/stop + Proton Pass secret
# fetch/cleanup used by the `vpn` fish function in pytheas.nix). Registers
# as walker/elephant provider "menus:vpn".
let
  vpnToggle = import ./vpn-toggle.nix { inherit pkgs; };
in
''
  Name = "vpn"
  NamePretty = "VPN"
  Icon = "network-vpn"
  Cache = false

  function GetEntries()
      local entries = {}
      local vpns = {${lib.concatMapStringsSep ", " (n: "\"${n}\"") vpnNames}}

      for _, name in ipairs(vpns) do
          local handle = io.popen("systemctl is-active --quiet openvpn-" .. name .. " && echo on || echo off")
          local state = handle:read("*l")
          handle:close()

          table.insert(entries, {
              Text = name,
              Subtext = state == "on" and "connected" or "disconnected",
              Icon = state == "on" and "network-vpn" or "network-vpn-disconnected",
              Actions = {
                  toggle = "${vpnToggle}/bin/vpn-toggle " .. name .. " " .. (state == "on" and "stop" or "start"),
              },
          })
      end

      return entries
  end
''
