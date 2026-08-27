{ pkgs }:
# Shared backend for the "menus:audio-mixer" walker/elephant menu (see
# audio-mixer-menu.nix): a no-arg call lists current playback streams
# (sink-inputs) as tab-separated "<index>\t<app-name>\t<volume%>\t<mute>"
# lines; called again as `raise|lower|mute <sink-input-index>` it adjusts
# that one stream via pactl, then the menu re-lists to reflect the change.
pkgs.writeShellApplication {
  name = "audio-mixer-select";
  runtimeInputs = [
    pkgs.pulseaudio
    pkgs.jq
  ];
  text = ''
    list() {
      pactl -f json list sink-inputs | jq -r '
        .[] | [
          .index,
          (.properties["application.name"] // .properties["media.name"] // "Unknown"),
          (.volume | to_entries[0].value.value_percent),
          .mute
        ] | @tsv
      '
    }

    case "''${1-}" in
      raise) pactl set-sink-input-volume "$2" +5% ;;
      lower) pactl set-sink-input-volume "$2" -5% ;;
      mute) pactl set-sink-input-mute "$2" toggle ;;
      "") ;;
      *)
        echo "usage: audio-mixer-select [raise|lower|mute] <sink-input-index>" >&2
        exit 1
        ;;
    esac

    list
  '';
}
