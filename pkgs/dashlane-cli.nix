{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "dashlane-cli";
  version = "6.2628.1";

  src = fetchurl {
    url = "https://github.com/Dashlane/dashlane-cli/releases/download/v${version}/dcli-linux-x64";
    hash = "sha256-mDq2Q+Ef4tVrFm5w/bWQcsDQMVyYCDwrKXQqaBXkWpM=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/dcli
    chmod +x $out/bin/dcli
  '';

  meta = {
    description = "Dashlane CLI";
    homepage = "https://github.com/Dashlane/dashlane-cli";
    license = { free = true; };
    mainProgram = "dcli";
  };
}
