{
  description = "Personal wallpapers and colorschemes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { nixpkgs, systems, ... }:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in rec {
      packages = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          selectColorscheme = import ./colorschemes/select-colorscheme.nix {
            inherit pkgs;
          };
        });
      # Filters the packages to include only those that are derivations
      hydraJobs = nixpkgs.lib.mapAttrs
        (_: nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation)) packages;
    };
}
