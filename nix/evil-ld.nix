{ lib
, craneLib
, ...
}:
with builtins;

let
  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../Cargo.toml
      ../Cargo.lock
      ../src
      ../.cargo
    ];
  };

  manifest = fromTOML (readFile ../Cargo.toml);

  commonArgs = {
    pname = manifest.package.name;
    version = manifest.package.version;

    src = craneLib.cleanCargoSource src;
    strictDeps = true;

    doCheck = false;
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in

craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; })
