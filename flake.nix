{
  description = "evil-ld";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    let
      overlay = final: prev: {
        evil-ld = final.callPackage ./nix/evil-ld.nix { };
      };
    
      mkPkgs = system: import nixpkgs {
        overlays = [ overlay ];
        inherit system;
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = mkPkgs system; in
      {
        packages.default = pkgs.evil-ld;

        devShells.default = pkgs.mkShell {
          packages = pkgs.evil-ld.nativeBuildInputs;
        };

        apps = flake-utils.lib.mkApp { drv = pkgs.evil-ld; };
      }
    );
}
