**Personal wallpapers and color schemes** — built with Nix.

This flake provides a collection of curated wallpapers and auto-generated color schemes (via [`matugen`](https://github.com/InverseGood/matugen)) for use in theming your Linux desktop environment, especially when using [NixOS](https://nixos.org) or [Home Manager](https://nix-community.github.io/home-manager/).

---

## 🧩 Flake Inputs

```nix
{
  description = "Personal wallpapers and colorschemes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };
}
```

---

## 📦 Exposed Packages

Each system defined in `systems` will build the following:

### 🎨 Wallpapers

Defined in `wallpapers/default.nix`

Fetched from `https://i.redd.it/...` using a JSON list

Available as:
+ `wallpapers`: An attrset of `name = derivation` for each wallpaper
+ `allWallpapers`: A `linkFarm` that bundles all wallpapers into a single directory

### 🌈 Colorschemes

+ Generated from either an image or a hex color source
+ Uses matugen to produce multiple color styles:
    + `content`: Brighter and more vivid color usage
    + `expressive`: Bolder and more vibrant, multi-colored scheme
    + `fidelity`: Attempts to stay as true as possible to the original input color
    + `fruit-salad`: Playful and colorful — a fun, varied scheme based loosely on fruit colors
    + `monochrome`: Pure grayscale scheme — no hue, just tone
    + `neutral`: Grayish versions of the base palette
    + `rainbow`: Distributes hues across the color spectrum, evenly spaced
    + `tonal-spot`: One "seed" color with tonal variations
+ Available as:
    + `colorschemes`: Attrset of generated schemes
    + `allColorschemes`: A `linkFarm` directory with all JSON scheme outputs, plus a combined `colorschemes.json` file for caching/importing

## 🔧 Using in Your Flake

You can import this flake into your own configuration like so:
```nix
{
  inputs.themes = {
    url = "github:YvesCousteau/nix-themes";
    inputs.systems.follows = "systems";
  };

  outputs = { themes, ... }: {
    # Access specific packages
    packages.x86_64-linux = {
      wallpaper = themes.packages.x86_64-linux.wallpapers.my-wallpaper;
      colorscheme = themes.packages.x86_64-linux.colorschemes.my-wallpaper;
    };
  };
}
```
Or to use the entire linkFarm directory (e.g., for setting wallpaper paths):
```nix
{
  environment.systemPackages = [
    themes.packages.x86_64-linux.allWallpapers
    themes.packages.x86_64-linux.allColorschemes
  ];
}
```

## 💡 Generator Details

The `colorschemes/generator.nix` file uses:
+ Custom-defined base colors
+ A TOML config passed to `matugen`
+ Smart detection for whether the input is an image or a hex code
+ Outputs one `.json` per scheme type, wrapped as a derivation

🧪 Hydra Integration

This flake supports Hydra CI out-of-the-box using a .hydra.json definition:
```json
{
  "main": {
    "enabled": 1,
    "type": 1,
    "hidden": false,
    "description": "Build main branch",
    "flake": "git://YvesCousteau/nix-themes?ref=main",
    "checkinterval": 60,
    "schedulingshares": 10,
    "enableemail": false,
    "emailoverride": "",
    "keepnr": 1
  }
}
```

Key Details:
+ enabled: `1` — Hydra will track this jobset.
+ type: `1` — Indicates this is a flake-based jobset.
+ flake: `git://YvesCousteau/nix-themes?ref=main` — Pulls the flake from your custom Git server.
+ checkinterval: `60` — Checks every 60 seconds for updates.
+ schedulingshares: `10` — Fair scheduling weight.
+ keepnr: `1` — Only keeps the latest successful build.

The actual derivations to be built by Hydra come from the hydraJobs output in your flake:

```nix
hydraJobs = nixpkgs.lib.mapAttrs (
  _: nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation)
) packages;
```

This ensures only valid derivations from packages are sent to Hydra, and it avoids things like attrsets or functions.

## 📁 Structure

```csharp
.
├── wallpapers/
│   ├── default.nix
│   └── list.json     # List of wallpapers (name, id, ext, sha256)
├── colorschemes/
│   ├── default.nix
│   └── generator.nix # matugen-based generator
├── .hydra.json       # Hydra job configuration
├── flake.nix

```

## ✨ Future Ideas

+ Add more color generators (e.g., pywal or base16)
+ Support custom image inputs for users
+ Extend metadata (e.g., resolution, tags)

## 🤝 Acknowledgements

This flake is inspired by the excellent work done in the [Misterio77/themes](https://github.com/Misterio77/themes) repository. Special thanks to the contributors of [matugen](https://github.com/InioX/matugen) for making color scheme generation easy.

## 📜 Wallpapers

+ [village-drawing-light](https://i.redd.it/18e6s5qy2bte1.png)
+ [sunset-forest-drawing-dark](https://i.redd.it/rknp4tfe3hyd1.jpeg)
+ [pipes-drawing-light](https://i.redd.it/qu6gsbfpzk1d1.png)
+ [snowing-train-drawing-dark](https://i.redd.it/7tnlkhjvjs8b1.jpg)
+ [fuji-landscape-drawing-light](https://i.redd.it/686p8bxm8twd1.png)
+ [jeep-beach-drawing-light](https://i.redd.it/8o1dlanrjp7d1.png)
+ [raining-night-house-drawing-dark](https://i.redd.it/dzm17cv8lwzd1.png)
+ [purple-night-porsche-drawing-dark](https://i.redd.it/khnhze4fgf0d1.png)
+ [numerical-earth-drawing-dark](https://i.redd.it/9rbfo0r5f0ue1.jpeg)


