{
  description = "My NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";

    nvim.url = "github:aaron70/nvim";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } { 
    systems = inputs.nixpkgs.lib.platforms.all;
    imports = [ 
      (inputs.import-tree ./modules) 
      inputs.wrappers.flakeModules.wrappers
      inputs.flake-parts.flakeModules.modules
      inputs.home-manager.flakeModules.home-manager
      inputs.nix-darwin.flakeModules.default
    ];
  };
}
