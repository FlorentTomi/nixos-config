{ ... }:
{
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = false;

  sops.secrets.hello = { };
}
