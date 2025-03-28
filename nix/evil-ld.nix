{ stdenv
, lib
, gcc_multi
, nasm
, gnumake
, moreutils
, ...
}:

let
  src = lib.fileset.unions [
    ../src
    ../Makefile
  ];
in

stdenv.mkDerivation {
  pname = "evil-ld";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = src;
  };

  nativeBuildInputs = [
    gcc_multi
    nasm
    gnumake
    moreutils
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out
    install -Dm755 ./evil-ld $out/bin/evil-ld
  '';
}
