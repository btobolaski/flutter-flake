{
  description = "<PROJECT-DESCRIPTION>"; ### TODO

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flutter-flake = {
      url    = "github:waotzi/flutter-flake/3.2.0";
      inputs.nixpkgs.follows  = "nixpkgs";
    };
  };

  outputs = { flutter-flake, nixpkgs, self }:
  let
    ### TODO other implement systems
    system = "x86_64-linux";
    pkgs   = import nixpkgs {
      inherit system;
    };
  in {
    devShell.${system} = pkgs.mkShell rec {
      inputsFrom = [ flutter-flake.devShell.${system} ];
    };
  };
}
