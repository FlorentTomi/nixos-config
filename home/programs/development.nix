{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.gh.enable = true;
  programs.zed-editor.enable = true;
  programs.claude-code = {
    enable = true;
    plugins = [
      (pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "v1.9.1";
        hash = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
      })
    ];
  };

  home.packages = [
    pkgs.nodejs_22
    pkgs.nil
    pkgs.nixd
  ];
}
