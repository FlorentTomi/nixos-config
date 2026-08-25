{ lib, ... }:
{
  # flake.modules.nixos.<name> / flake.modules.homeManager.<name> are no
  # longer declared here — they come from flake-parts' own `modules`
  # extension (see flake.nix), which is the same
  # lazyAttrsOf-deferredModule shape as before: same-name definitions
  # still merge instead of erroring, so the duplicate-name caveat is
  # unchanged, we just no longer maintain the option ourselves.
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
