{
  homeManager.modules.fastfetch = {
    programs.fish.interactiveShellInit = ''
      fastfetch
    '';

    programs.fastfetch = {
      enable = true;
      settings = {
        display.separator = ": ";
        modules = [
          {
            type = "custom";
            format = "┌─────────────────────────────────────────────────────────┐";
          }
          {
            type = "os";
            key = "   OS";
          }
          {
            type = "kernel";
            key = "  󰌽 Kernel";
          }
          {
            type = "packages";
            key = "  󰏓 Packages";
          }
          {
            type = "display";
            key = "  󰍹 Display";
          }
          {
            type = "wm";
            key = "   WM";
            format = "{2}";
          }
          {
            type = "terminalfont";
            key = "   Font";
          }
          {
            type = "terminal";
            key = "   Terminal";
            format = "{1}";
          }
          {
            type = "shell";
            format = "{1} {4}";
            key = "   Shell";
          }
          {
            type = "custom";
            format = "└─────────────────────────────────────────────────────────┘";
          }
          "break"
          {
            type = "title";
            key = "  ";
          }
          {
            type = "custom";
            format = "┌─────────────────────────────────────────────────────────┐";
          }
          {
            type = "cpu";
            format = "{1}";
            key = "   CPU";
          }
          {
            type = "gpu";
            format = "{1} {2} {12} Ghz";
            key = "  󱓞 GPU";
          }
          {
            type = "memory";
            key = "   Memory";
          }
          {
            type = "command";
            key = "  󱦟 OS Age ";
            text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
          }
          {
            type = "uptime";
            key = "  󱫐 Uptime ";
          }
          {
            type = "host";
            key = "   Machine";
            format = "{name}{?vendor} ({vendor}){?}";
          }
          {
            type = "custom";
            format = "└─────────────────────────────────────────────────────────┘";
          }
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
