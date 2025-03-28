{ stdenv
, lib
, gcc_multi
, nasm
, gnumake
, coreutils
, moreutils
, patchelf
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
    coreutils
    moreutils
    patchelf
  ];

  buildPhase = ''
    # Allow overriding with `.overrideAttrs { REAL_LD = "..."; }`.
    if [ -z "$REAL_LD" ]; then
      # Take the interpreter from coreutils.
      export REAL_LD="$(patchelf --print-interpreter "${coreutils}/bin/coreutils")"
    fi

    make
  '';

  installPhase = ''
    mkdir -p $out
    install -Dm755 ./evil-ld $out/bin/evil-ld
  '';
}
