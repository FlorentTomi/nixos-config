{ lib, vpnNames }:
# elephant menu definition (~/.config/elephant/menus/vpn.lua): lists VPNs
# with live on/off state and toggles the matching openvpn-<name> unit on
# select. Registers as walker/elephant provider "menus:vpn".
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
                  toggle = "sh -c 'systemctl is-active --quiet openvpn-" .. name .. " && systemctl stop openvpn-" .. name .. " || systemctl start openvpn-" .. name .. "'",
              },
          })
      end

      return entries
  end
''
