{ pkgs, ... }:
let
  inherit (pkgs) lib;
  generateColorscheme =
    name: source:
    let
      schemeTypes = [
        "content" # Brighter and more vivid color usage
        "expressive" # Bolder and more vibrant, multi-colored scheme
        "fidelity" # Attempts to stay as true as possible to the original input color
        "fruit-salad" # Playful and colorful — a fun, varied scheme based loosely on fruit colors
        "monochrome" # Pure grayscale scheme — no hue, just tone
        "neutral" # Grayish versions of the base palette
        "rainbow" # Distributes hues across the color spectrum, evenly spaced
        "tonal-spot" # One "seed" color with tonal variations
      ];
      isHexColor = c: lib.isString c && (builtins.match "#([0-9a-fA-F]{3}){1,2}" c) != null;

      # Generates a TOML configuration file
      config = (pkgs.formats.toml { }).generate "config.toml" {
        templates = { };
        config = {
          # Custom color definitions that will be used in generating the color schemes
          custom_colors = {
            red = "#dd0000";
            orange = "#dd5522";
            yellow = "#dddd00";
            green = "#22dd22";
            cyan = "#22dddd";
            blue = "#2222dd";
            magenta = "#dd22dd";
          };
        };
      };
    in
    # Defines a command that will be run to generate the color schemes
    # Tool matugen is used for generating color schemes
    pkgs.runCommand "colorscheme-${name}"
      {
        passthru =
          let
            # The source can be either a hex color code or an image file.
            drv = generateColorscheme name source;
          in
          {
            # The list of scheme types
            inherit schemeTypes;
            # A dynamically generated attribute set where each scheme type is associated with the imported JSON data
            imported = lib.genAttrs schemeTypes (scheme: lib.importJSON "${drv}/${scheme}.json");
          };
      }
      ''
        # Creates a directory for the output
        mkdir "$out" -p
        # Iterates over each scheme type defined
        for type in ${lib.concatStringsSep " " schemeTypes}; do
          # Uses matugen to generate a color scheme based on the source
          ${pkgs.matugen}/bin/matugen ${
            if (isHexColor source) then "color hex" else "image"
          } --config ${config} -j hex -t "scheme-$type" "${source}" > "$out/$type.json"
        done
      '';
in
generateColorscheme
