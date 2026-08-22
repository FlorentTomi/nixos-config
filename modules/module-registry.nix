{ lib, ... }:
{
  # Each key below must be defined by exactly one file — lazyAttrsOf merges
  # same-name definitions instead of erroring, so duplicate names would
  # silently combine rather than fail.
  options.nixos.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };
  options.homeManager.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          user = lib.mkOption { type = lib.types.str; };
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
          };
          diskDevice = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
    default = { };
  };
}
