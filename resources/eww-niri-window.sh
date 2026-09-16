#!@bash@
PATH=@bin@
emit() {
  ws=$(niri msg -j workspaces)
  wins=$(niri msg -j windows)
  jq -nc --argjson ws "$ws" --argjson wins "$wins" '
    reduce ( $ws[] | select(.is_active) ) as $w ({};
      . + { ($w.output // "unknown"):
            ( [ $wins[] | select(.workspace_id == $w.id) ] as $c
              | ( first($c[] | select(.is_focused)) // $c[0] // null )
              | if . == null
                then { title: "", app: "", floating: false }
                else { title: (.title // ""), app: (.app_id // ""),
                       floating: (.is_floating // false) }
                end ) })'
}
emit
# Workspace switches change which window an output is showing, so this
# listens to workspace events too, not just window ones.
niri msg -j event-stream \
  | jq --unbuffered -nc 'inputs
      | if has("WindowFocusChanged") or has("WindowsChanged") or has("WindowOpenedOrChanged")
           or has("WindowClosed") or has("WorkspaceActivated") or has("WorkspacesChanged")
        then "refresh" else empty end' \
  | while read -r _; do emit; done
