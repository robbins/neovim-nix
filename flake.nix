{
  description = "Nate's NixVim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { nixvim, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          cfg = nixvim.lib.evalNixvim {
            inherit system;

            modules = [ ./config ];

            extraSpecialArgs = {
            };
          };
        in
        {
          checks.default = cfg.config.build.test;
          formatter = pkgs.nixfmt-tree;
          packages.default = cfg.config.build.package;
        };
    };
}
