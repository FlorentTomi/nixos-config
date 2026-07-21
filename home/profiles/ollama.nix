{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
  };
}
