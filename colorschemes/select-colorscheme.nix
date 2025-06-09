{ pkgs, ... }:
let
  schemesDir = ./../colorschemes/generated;
  selectColorscheme = wallpaper: type:
    let
      wallpaperBase = builtins.baseNameOf (toString wallpaper);
      nameNoExt = builtins.replaceStrings [ ".png" ".jpg" ".jpeg" ] [ "" "" "" ]
        wallpaperBase;
      file = "${schemesDir}/${nameNoExt}-${type}.json";
    in pkgs.runCommand "select-colorscheme" {
      passthru = {
        content = file;
        parsed = builtins.fromJSON (builtins.readFile file);
      };
    } ''
      set -euo pipefail

      echo "✅ Found colorscheme: ${file}"
      cat "${file}" > "$out"
    '';
in selectColorscheme

