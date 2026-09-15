final: prev: {
  volctl = prev.rustPlatform.buildRustPackage rec {
    pname = "volctl";
    version = "1.0.0";

    src = prev.fetchFromGitHub {
      owner = "buzz";
      repo = "volctl";
      rev = "v${version}";
      hash = "sha256-vyZKIn7QBVmB4Xa8tui5aqlRcIG697EnmVyM071TZGU=";
    };

    cargoHash = "sha256-SnbF7KbJ0IbjagbK8dCkQmuk3SmNJypTWu8zzww+4/4=";

    nativeBuildInputs = with prev; [
      pkg-config
      wrapGAppsHook4
      glib
    ];

    buildInputs = with prev; [
      cairo
      glib
      gtk4
      gtk4-layer-shell
      libpulseaudio
      libxfixes
    ];

    postInstall = ''
      install -Dm644 data/apps.volctl.gschema.xml \
        "$out/share/glib-2.0/schemas/apps.volctl.gschema.xml"
      glib-compile-schemas "$out/share/glib-2.0/schemas"
      ls -la "$out/share/glib-2.0/schemas/"
    '';

    postFixup = ''
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : "$out/share/gsettings-schemas/$name"
      )
    '';

    meta = with prev.lib; {
      description = "Per-application volume control and OSD for Linux desktops (Rust/SNI rewrite)";
      homepage = "https://buzz.github.io/volctl/";
      license = licenses.gpl3Only;
      mainProgram = "volctl";
      platforms = platforms.linux;
    };
  };
}
