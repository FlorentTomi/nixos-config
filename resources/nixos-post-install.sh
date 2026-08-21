#!/usr/bin/env bash
# nixos-post-install — run once after first boot of a freshly disko-installed
# host, from the -base install target. Reattaches real git history to the
# baked-in repo copy, switches to the full config, and reboots — the reboot
# is what makes the newly-installed kernel/bootloader/GPU driver live, and
# is also what makes NH_FLAKE (a login-time session variable) resolve
# correctly in future shells. Safe to re-run; each step no-ops if already
# done.
set -euo pipefail

HOST="${1:-$(hostname)}"
REPO_DIR="$HOME/nixos-config"
REPO_URL="git@github.com:FlorentTomi/nixos-config.git"

echo "== Post-install for host: $HOST =="

if [ ! -d "$REPO_DIR" ]; then
  echo "error: $REPO_DIR not found — was this installed via the custom ISO?" >&2
  exit 1
fi

# --extra-files copies as root; fix ownership before touching it.
if [ "$(stat -c %U "$REPO_DIR")" != "$(whoami)" ]; then
  echo "-> fixing ownership of $REPO_DIR"
  sudo chown -R "$(whoami)": "$REPO_DIR"
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "-> no git history present, attempting to fetch it"
  if git ls-remote "$REPO_URL" &>/dev/null; then
    TMP=$(mktemp -d)
    git clone "$REPO_URL" "$TMP"
    mv "$TMP/.git" "$REPO_DIR/.git"
    rm -rf "$TMP"
    ( cd "$REPO_DIR" && git checkout -- . 2>/dev/null || true )
    echo "-> git history attached"
  else
    echo "-> no network reachable to $REPO_URL yet, skipping (working tree still usable)"
  fi
else
  echo "-> git history already present, skipping clone"
fi

# NH_FLAKE is set via NixOS's environment.variables, which only lands in
# /etc/set-environment — read at LOGIN, not by shells already running.
# This session predates the switch, so -H is required here regardless of
# whether NH_FLAKE ends up correct; don't rely on it in this script.
echo "-> switching to $HOST (explicit -H, this session predates the switch)"
cd "$REPO_DIR"
nh os switch -H "$HOST"

echo
echo "== First switch complete =="
echo "This installed a new kernel, bootloader entry, and GPU driver —"
echo "all of which need a reboot to take effect, same as any other"
echo "kernel/bootloader/driver change on this config."
echo
echo "It's also the same reboot that fixes NH_FLAKE: it's a login-time"
echo "session variable, so this current shell won't see it no matter"
echo "how long you wait — only a fresh login (i.e. this reboot) will."
echo
read -p "Reboot now? [Y/n] " ans
if [[ ! "$ans" =~ ^[Nn] ]]; then
  sudo reboot
else
  echo "Remember to reboot before things like the GPU driver, and plain"
  echo "'nh os switch' without -H, will work correctly."
fi
