{
  description = "evil-ld";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";
  };

  outputs = { nixpkgs, flake-utils, rust-overlay, crane, ... }:
    let
      mkPkgs = system: import nixpkgs {
        overlays = [
          (import rust-overlay)

          (final: _: rec {
            rustToolchain = final.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
            craneLib = (crane.mkLib final).overrideToolchain (_: rustToolchain);
          })

          (final: _: {
            evil-ld = final.callPackage ./nix/evil-ld.nix { };
          })
        ];
        inherit system;
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = mkPkgs system; in
      {
        packages.default = pkgs.evil-ld;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ rustToolchain ];

          RUST_BACKTRACE = 1;
          CARGO_BUILD_TARGET = "i686-unknown-linux-musl";
        };

        apps = flake-utils.lib.mkApp { drv = pkgs.evil-ld; };
      }
    );
}
