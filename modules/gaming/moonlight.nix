{
  # Streams games from the gaming desktop (modules/sunshine.nix). This is
  # the client side.
  homeManager.modules.moonlight =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.moonlight-qt ];
    };
}
