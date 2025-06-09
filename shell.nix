{ pkgs ? import <nixpkgs> { } }:
let lib = pkgs.lib;

in pkgs.mkShell {
  buildInputs = [ pkgs.matugen pkgs.jq ];

  wallpapers = "./wallpapers/list.json";
  wallpapersDownloadDir = "./wallpapers/downloaded";
  colorschemeResultDir = "./colorschemes/generated";
  matugenConfig = "./config.toml";
  matugenExe = lib.getExe pkgs.matugen;
  types = [
    "content"
    "expressive"
    "fidelity"
    "fruit-salad"
    "monochrome"
    "neutral"
    "rainbow"
    "tonal-spot"
  ];

  shellHook = ''
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p "$wallpapersDownloadDir"
    mkdir -p "$colorschemeResultDir"

    if [ ! -f "$matugenConfig" ]; then
      echo "Config file $matugenConfig does not exist!"
      exit 1
    fi

    if [ -z "$matugenExe" ]; then
      echo "matugen not found in PATH"
      exit 1
    fi

    echo "Reading wallpapers from $wallpapers..."

    jq -c '.[] | {id, ext, name}' "$wallpapers" | while read -r wallpaper; do
      id=$(jq -r '.id' <<< "$wallpaper")
      ext=$(jq -r '.ext' <<< "$wallpaper")
      name=$(jq -r '.name' <<< "$wallpaper")

      url="https://i.redd.it/$id.$ext"
      local_file="$wallpapersDownloadDir/$name.$ext"

      echo "Downloading $name from $url ..."
      curl -L --fail --output "$local_file" "$url"


      for type in $types; do
        echo "Generating color schemes for $name-$type..."
        "$matugenExe" image --config "$matugenConfig" -j hex -t "scheme-$type" "$local_file" > "$colorschemeResultDir/$name-$type.json"
      done

      echo "Finished $name"
    done

    echo "All wallpapers processed."
    exit
  '';
}
