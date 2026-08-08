{ osConfig }:
# osConfig's own VPN list (modules/openvpn.nix), not a systemctl unit-name
# glob: services.openvpn also creates its own internal units matching
# "openvpn-*" (e.g. openvpn-restart.service, a sleep/resume hook) that
# aren't actual VPNs and would otherwise leak into anything iterating units.
map (c: c.name) osConfig.modules.openvpn.configs
