{ select }:
# elephant menu definition (~/.config/elephant/menus/audio-mixer.lua): lists
# every app currently playing audio with its volume/mute state, and exposes
# raise/lower/mute actions per entry (bound to keys in
# programs.walker.config.providers.actions."menus:audio-mixer", see
# walker.nix). Registers as walker/elephant provider "menus:audio-mixer".
''
  Name = "audio-mixer"
  NamePretty = "Audio Mixer"
  Icon = "audio-volume-high"
  Cache = false

  function GetEntries()
      local entries = {}
      local handle = io.popen("${select}/bin/audio-mixer-select")

      if handle then
          for line in handle:lines() do
              local id, name, vol, mute = line:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")

              if id then
                  table.insert(entries, {
                      Text = name,
                      Subtext = (mute == "true") and (vol .. " (muted)") or vol,
                      Icon = (mute == "true") and "audio-volume-muted" or "audio-volume-high",
                      Actions = {
                          raise = "${select}/bin/audio-mixer-select raise " .. id,
                          lower = "${select}/bin/audio-mixer-select lower " .. id,
                          mute = "${select}/bin/audio-mixer-select mute " .. id,
                      },
                  })
              end
          end
          handle:close()
      end

      if #entries == 0 then
          table.insert(entries, {
              Text = "Nothing playing audio right now",
              Subtext = "",
          })
      end

      return entries
  end
''
