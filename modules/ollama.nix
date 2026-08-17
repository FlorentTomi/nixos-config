{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.ollama;
in
{
  options.modules.ollama.enable = lib.mkEnableOption "Ollama LLM server (CUDA-accelerated, LAN-exposed)";

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama;
      acceleration = "cuda";
      host = "0.0.0.0";
      port = 11434;
    };
  };
}
