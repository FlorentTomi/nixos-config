_:
{
  flake.modules.nixos.automount = {
    services.udisks2.enable = true;
  };

  flake.modules.homeManager.automount =
    _:
    {
      services.udiskie = {
        enable = true;
      };
    };
}
