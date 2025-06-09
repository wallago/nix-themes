{ pkgs }:
pkgs.lib.listToAttrs (map (wallpaper: {
  inherit (wallpaper) name;
  value = ./. + "/downloaded/${wallpaper.name}.${wallpaper.ext}";
}) (pkgs.lib.importJSON ./list.json))
