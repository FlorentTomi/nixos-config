{
  homeManager.modules.sops-env = {
    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
    };
  };
}
