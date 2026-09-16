#!@bash@
PATH=@bin@
emit() {
  niri msg -j workspaces \
    | jq -c '[.[] | {id, idx, output: (.output // "unknown"),
                     active: .is_active, urgent: (.is_urgent // false)}]
             | sort_by(.output, .idx)'
}
emit
niri msg -j event-stream \
  | jq --unbuffered -nc 'inputs | select(has("WorkspacesChanged") or has("WorkspaceActivated") or has("WorkspaceUrgencyChanged"))' \
  | while read -r _; do emit; done
