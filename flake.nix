{
  description = "A basic AppImage bundler";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs { inherit system; }).pkgsStatic;
      in
      rec {
        packages.appimage-runtimes = {
          appimage-type2-runtime = pkgs.callPackage ./runtimes/appimage-type2-runtime { };
        };

        packages.appimage-appruns = {
          bwrap = pkgs.callPackage ./appruns/bwrap { };
        };

        lib.mkAppImage = pkgs.callPackage ./mkAppImage.nix {
          mkappimage-runtime = packages.appimage-runtimes.appimage-type2-runtime;
          mkappimage-apprun = packages.appimage-appruns.bwrap;
        };

        bundlers.default = drv:
          if drv.type == "app" then
            lib.mkAppImage
              {
                program = drv.program;
              }
          else if drv.type == "derivation" then
            lib.mkAppImage
              {
                program = pkgs.lib.getExe drv;
              }
          else builtins.abort "don't know how to build ${drv.type}; only know app and derivation";

        checks =
          let
            # use regular (non-static) nixpkgs
            pkgs = import nixpkgs { inherit system; };
            hello-appimage = bundlers.default pkgs.hello;
          in
          {
            hello-is-static = pkgs.runCommand "check-hello-is-static"
              {
                nativeBuildInputs = [ (pkgs.lib.getBin pkgs.stdenv.cc.libc) ];
              } ''
              (! ldd ${hello-appimage} 2>&1) | grep "not a dynamic executable"
              touch $out
            '';
          };
      });
}
