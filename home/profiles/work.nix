# Everything needed to work in Pytheas repos on this host: the SSH key for
# GitLab, and an automatic git identity swap for any repo whose remote
# points at pytheasnavigation.com — so committing there always uses the
# work name/email regardless of where the repo lives on disk, with no
# manual switching required.
{ osConfig, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

    settings."git.pytheasnavigation.com" = {
      # was: matchBlocks."git.pytheasnavigation.com"
      identityFile = osConfig.sops.secrets."ssh-key-pytheas_gitlab".path;
      identitiesOnly = true;
    };
  };

  programs.git.includes = [
    {
      condition = "hasconfig:remote.*.url:**pytheasnavigation.com**";
      contents.user = {
        name = "Florent TOMI";
        email = "florent.tomi@pytheasnavigation.com";
      };
    }
  ];
}
