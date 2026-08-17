{ ... }:

{
  wayland.windowManager.niri.settings._children = [
    {
      window-rule._children = [
        { match._props.app-id = "^steam_app_.*$"; }
        { open-maximized = true; }
      ];
    }
  ];
}
