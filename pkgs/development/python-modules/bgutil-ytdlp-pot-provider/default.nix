{
  lib,
  buildPythonPackage,
  cairo,
  fetchFromGitHub,
  fetchNpmDeps,
  giflib,
  hatchling,
  nodejs,
  npmHooks,
  pango,
  pixman,
  pkg-config,
  yt-dlp,
}:

buildPythonPackage rec {
  pname = "bgutil-ytdlp-pot-provider";
  version = "1.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Brainicism";
    repo = "bgutil-ytdlp-pot-provider";
    tag = version;
    hash = "sha256-vlhuw0Ci/xfPgLxjeW7E+Pz9Fo6yeME3cyVRf8NAAPU=";
  };

  npmDeps = fetchNpmDeps {
    name = "${pname}-${version}-npm-deps";
    src = src + "/server";
    npmDepsFetcherVersion = 2;
    hash = "sha256-hpXVvhJm66+ETJdGAbEa/QZ4rxOYBD8RJqSItlNpoOg=";
  };

  npmRoot = "server";

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ];

  buildInputs = [
    cairo
    giflib
    pango
    pixman
  ];

  build-system = [ hatchling ];

  dependencies = [ ];

  doCheck = false; # no tests

  preBuild = ''
    cp README.md plugin/
    cp README.md server/
    cd server
    npx tsc
    npm prune --omit=dev
    cd ../plugin
  '';

  postInstall = ''
    cd ..

    mkdir -p $out/share/bgutil-ytdlp-pot-provider/
    cp -r server/{build,node_modules} $out/share/bgutil-ytdlp-pot-provider/
    makeWrapper ${lib.getExe nodejs} $out/bin/bgutil-ytdlp-pot-provider \
      --add-flags $out/share/bgutil-ytdlp-pot-provider/build/main.js

    cd plugin
  '';

  meta = {
    description = "Proof-of-origin token provider plugin for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "bgutil-ytdlp-pot-provider";
  };
}
