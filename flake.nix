{
  description = "A flake to manage a flutter-development-environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    devshell = {
      url = "github:numtide/devshell";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };


  outputs = { self, nixpkgs, flake-utils, devshell, rust-overlay }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
        overlays = [
          devshell.overlays.default
          rust-overlay.overlays.default
        ];
      };

      rustc = pkgs.rust-bin.stable."1.71.0".default.override {
        extensions = ["rust-src"];
        targets = ["aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android" "wasm32-unknown-unknown"];
      };

      buildToolsVersion = "31.0.0";

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        toolsVersion = "26.1.1";
        platformToolsVersion = "33.0.3";
        buildToolsVersions = [ buildToolsVersion ];
        includeEmulator = false;
        emulatorVersion = "31.3.10";
        platformVersions = [ "33" ];
        includeSources = false;
        includeSystemImages = false;
        systemImageTypes = [ "google_apis_playstore" ];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        includeNDK = true;
        ndkVersions = [ "22.0.7026061" ];
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
      };
      androidSdk = androidComposition.androidsdk;

    in rec {
      overlay = final: prev: {
        inherit (self.packages);
      };

      packages = [
        androidComposition.platform-tools
        androidSdk
      ];

      devShell = import ./devshell.nix {
        inherit pkgs androidSdk androidComposition buildToolsVersion rustc;
      };
    }) // {
      templates = {
        flutter = {
          path        = ./template;
          description = "A flutter development environment";
        };
      };
      defaultTemplate = self.templates.flutter;
    };
}
