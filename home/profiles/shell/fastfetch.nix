{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      display.separator = ": ";
      modules = [
        "title"
        "os"
        "kernel"
        "uptime"
        "cpu"
        {
          type = "gpu";
          detectionMethod = "vulkan";
          format = "{2}";
        }
        "memory"
        "disk"
      ];
    };
  };
}
