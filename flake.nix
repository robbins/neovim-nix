{
  description = "Nate's NixVim configuration";

  inputs = {
    nixvim.url = "github:nix-community/nixvim";
    nixpkgs.follows = "nixvim/nixpkgs";
    flake-parts.follows = "nixvim/flake-parts";
  };

  outputs =
    { nixvim, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      transposition.nixvimConfigurations = {
        adHoc = true;
      };

      perSystem =
        { pkgs, system, ... }:
        let
          base = nixvim.lib.evalNixvim {
            inherit system;

            modules = [ ./config ];

            extraSpecialArgs = {
            };
          };
          plugins = base.config.plugins;
        in
        {
          checks.default = base.config.build.test;
          formatter = pkgs.nixfmt-tree;
          packages = {
            default = base.config.build.package;
          } // builtins.mapAttrs (name: plugin: plugin.package) plugins;
          nixvimConfigurations.default = base;
        };
    };
}
