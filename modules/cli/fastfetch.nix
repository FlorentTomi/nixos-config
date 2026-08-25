{
  flake.modules.homeManager.fastfetch = {
    programs.fish.interactiveShellInit = ''
      fastfetch
    '';

    programs.fastfetch = {
      enable = true;
      settings = {
        display = {
          disableLinewrap = true;
          separator = " 󰁔 ";
          key = {
            type = "both";
          };
        };

        modules = [
          {
            type = "title";
          }
          "Break"
          {
            type = "OS";
            key = "OS";
          }
          {
            type = "Kernel";
            key = "Kernel";
          }
          {
            type = "Packages";
            key = "Packages";
          }
          {
            type = "shell";
            key = "Shell";
          }
          {
            type = "WM";
            key = "WM";
          }
          {
            type = "display";
            key = "Display";
          }
          {
            type = "cpu";
            format = "{1}";
            key = "CPU";
          }
          {
            type = "gpu";
            format = "{1} {2}";
            key = "GPU";
          }
          {
            type = "memory";
            key = "Memory";
          }
          {
            type = "Btrfs";
            key = "Disk";
          }
          "break"
          {
            type = "command";
            key = "OS Age";
            text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
          }
          "break"
          {
            type = "colors";
            paddingLeft = 2;
            symbol = "circle";
          }
          "break"
        ];
      };
    };
  };
}
