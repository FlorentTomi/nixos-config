{
  flake.modules.homeManager.ssh-ftomi-rpi = {
    programs.ssh.settings."ftomi-rpi" = {
      hostname = "192.168.1.21";
      user = "ftomi";
    };
  };
}
