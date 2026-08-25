{
  flake.modules.nixos.oomd = {
    systemd.oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
    };

    boot.kernel.sysctl."vm.swappiness" = 150;
  };
}
