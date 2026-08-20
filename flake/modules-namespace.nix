# Bootstrap for the dendritic pattern: `flake.modules.<class>.<name>` is NOT
# a standard flake output, so flake-parts' freeform `flake` option won't
# accept it until we declare it ourselves. This is that declaration.
#
# `deferredModule` stores each entry as an *unevaluated* NixOS/Home Manager
# module (a function or attrset, not yet merged into any config) — exactly
# what you want to drop into another module's `imports = [ ... ]` list.
#
# Two levels: flake.modules.nixos.<name>, flake.modules.homeManager.<name>.
{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = ''
      Named, reusable module fragments ("dendrites"), organized by module
      class (nixos, homeManager, ...) then by feature name. Consumed via
      the `flakeModules` specialArg threaded through lib/mk-host.nix.
    '';
  };
}
