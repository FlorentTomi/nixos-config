{
  nixos.modules.zram = {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
      algorithm = "zstd";
    };
  };
}
