{ catppuccinScss, ... }:

{
  programs.eww = {
    enable = true;
    systemd.enable = true;
    scssConfig = catppuccinScss {
      text = builtins.readFile ./resources/eww-style.scss;
    };
    yuckConfig = ''
      ${builtins.readFile ./resources/eww-config.yuck}
    '';
  };
}
