{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
  };

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
