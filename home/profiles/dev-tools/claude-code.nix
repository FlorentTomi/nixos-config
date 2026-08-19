{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    plugins.caveman = (
      pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "v1.9.1";
        hash = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
      }
    );
  };
}
