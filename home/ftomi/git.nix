{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "Florent TOMI";
      email = "florent.tomi@outlook.com";
    };
  };
}
