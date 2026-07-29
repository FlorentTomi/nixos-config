# Mod+E (open yazi in a terminal) assumes profiles/shell.nix's ghostty is present.
{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
  };

  programs.niri.settings.binds."Mod+E".action.spawn = [
    "ghostty"
    "--confirm-close-surface=false"
    "-e"
    "yazi"
  ];

  home.packages = with pkgs; [
    ffmpegthumbnailer # video thumbnails
    ffmpeg # video metadata/processing
    poppler # pdf previews
    imagemagick # image previews/conversion
    unar # archive previews (zip, rar, 7z etc.)
    jq # json previews
    fd # fast file finder, used by yazi's search
    ripgrep # used for file content search
    fzf # fuzzy finder integration
  ];
}
