{ ... }:
{
  # Keep an eye on wear/health on an older drive.
  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };
}
