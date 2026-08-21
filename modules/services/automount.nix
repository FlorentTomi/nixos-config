{ ... }:
{
  nixos.modules.automount = {
    services.udisks2.enable = true;
  };

  homeManager.modules.automount =
    { ... }:
    {
      services.udiskie = {
        enable = true;
      };
    };
}
