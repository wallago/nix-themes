{
  description = "Personal wallpapers and colorschemes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    rec {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          # A collection of wallpapers
          wallpapers = import ./wallpapers { inherit pkgs; };
          # Creates a link farm (a directory with symbolic links) for all wallpapers.
          allWallpapers = pkgs.linkFarmFromDrvs "wallpapers" (pkgs.lib.attrValues wallpapers);

          # A color scheme generator
          generateColorscheme = import ./colorschemes/generator.nix { inherit pkgs; };
          colorschemes = import ./colorschemes { inherit pkgs wallpapers generateColorscheme; };

          # Creates a link farm for all color schemes
          allColorschemes =
            let
              # This is here to help us keep IFD cached (hopefully)
              combined = pkgs.writeText "colorschemes.json" (
                builtins.toJSON (pkgs.lib.mapAttrs (_: drv: drv.imported) colorschemes)
              );
            in
            pkgs.linkFarmFromDrvs "colorschemes" (pkgs.lib.attrValues colorschemes ++ [ combined ]);
        }
      );
      # Filters the packages to include only those that are derivations
      hydraJobs = nixpkgs.lib.mapAttrs (
        _: nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation)
      ) packages;
    };
}
