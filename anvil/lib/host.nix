{
  inputs,
  self,
  lib,
  config,
  ...
}:
with lib; let
  anvilHosts = config.anvil.hosts;
in {
  flake.lib.getInput = name:
    if inputs ? ${name}
    then inputs.${name}
    else throw "anvil: no flake input named '${name}'. Referenced from a host's target `pkgs`; is it declared in flake.nix?";

  flake.lib.getDefaultTarget = name: {
    outName = name;
    pkgs = "nixpkgs";
  };

  flake.lib.getTarget = system: entry: name: let
    defaultPkgs = "nixpkgs";
  in
    if isString entry
    then {
      outName = entry;
      pkgs = defaultPkgs;
    }
    else {
      outName = self.lib.getPropertyOrDefault entry "name" name;
      pkgs = self.lib.getPropertyOrDefault entry "pkgs" defaultPkgs;
    };

  flake.lib.getHost = name:
    if anvilHosts ? ${name}
    then anvilHosts.${name}
    else throw "Anvil: Host '${name}' not found. Did you forget to set anvil.hosts.${name}?";

  flake.lib.checkSystem = platform: hostName: host: system: pkgs: let
    input = self.lib.getInput pkgs;
    inputName = pkgs;
  in
    if ! (input.legacyPackages ? ${system})
    then throw "anvil: host '${hostName}' declares unsupported system '${system}' for its ${platform} target under the nixpkgs input '${inputName}'"
    else if platform == "nixos" && builtins.match ".*-darwin" system != null
    then throw "anvil: host '${hostName}' declares a NixOS target on the non-Linux system '${system}'"
    else if platform == "darwin" && builtins.match ".*-linux" system != null
    then throw "anvil: host '${hostName}' declares a darwin target on the non-darwin system '${system}'"
    else system;

  flake.lib.getHostSystemTargets = platform: hostName: host: let
    systems = host.systems.${platform};
    name = self.lib.getPropertyOrDefault host "name" hostName;
    targets =
      if isString systems
      then {${systems} = self.lib.getDefaultTarget name;}
      else mapAttrs (system: entry: self.lib.getTarget system entry name) systems;
  in
    if host.${platform} == null
    then
      if systems == null
      then {}
      else throw "anvil: host '${name}' sets anvil.hosts.${hostName}.systems.${platform} but declares no ${platform} fragment"
    else if systems == null
    then throw "anvil: host '${name}' has a ${platform} fragment but anvil.hosts.${hostName}.systems.${platform} is unset"
    else if targets == {}
    then throw "anvil: host '${name}' has a ${platform} fragment but anvil.hosts.${hostName}.systems.${platform} declares no target"
    else if length (unique (map (t: t.outName) (attrValues targets))) != length (attrValues targets)
    then throw "anvil: host '${name}' declares multiple ${platform} targets with the same output name"
    else mapAttrs' (system: target: nameValuePair (self.lib.checkSystem platform name host system target.pkgs) target) targets;

  flake.lib.mkHosts = platform: builder: let
    hostTargets =
      map
      (hostName: let
        host = self.lib.getHost hostName;
      in {
        inherit hostName;
        targets = self.lib.getHostSystemTargets platform hostName host;
      })
      (attrNames anvilHosts);

    byTarget =
      zipAttrsWith (_: hosts: unique hosts)
      (map ({
        hostName,
        targets,
      }:
        mapAttrs' (_: target: nameValuePair target.outName hostName) targets)
      hostTargets);

    conflicts =
      attrValues (mapAttrs (name: hosts: {inherit name hosts;})
        (filterAttrs (_: hosts: length hosts > 1) byTarget));
  in
    if conflicts != []
    then
      throw ''
        anvil: Multiple hosts produce the same ${platform} configuration name:
        ${concatMapStringsSep "\n" (c: "  -> '${c.name}' is produced by: ${concatStringsSep ", " c.hosts}") conflicts}
        If the hosts have the same name, you can set an alias for the configuration name by setting `systems.${platform} = { "<system>" = "<alias>" };`.
      ''
    else
      foldl'
      (acc: {
        targets,
        hostName,
        ...
      }: let
        host = self.lib.getHost hostName;
        namedHost =
          if host.name != null
          then host
          else host // {name = hostName;};
      in
        acc // mapAttrs' (system: target: nameValuePair target.outName (builder system namedHost target)) targets)
      {}
      hostTargets;

  flake.lib.getHostModules = platform: host: let
    ctx = {inherit host;};
    entityCtx = {
      inherit host;
      user = null;
    };
    childrenPrograms = self.lib.getProgramsList host entityCtx;
    childrenFeatures = self.lib.getFeaturesList host entityCtx;
    childrenUsers = self.lib.getUsersList host entityCtx;
    acc =
      self.lib.getProgramsModules
      (self.lib.getFeaturesModules {} platform "Host" host entityCtx childrenFeatures)
      platform "Host"
      host
      entityCtx
      childrenPrograms;
  in
    [
      (self.lib.withContext ctx (self.lib.getPropertyOrDefault host platform {}))
    ]
    ++ (self.lib.getUsersModules platform host childrenUsers)
    ++ attrValues acc.features
    ++ attrValues acc.programs;

  flake.lib.mkNixosConfiguration = system: host: target:
    (self.lib.getInput target.pkgs).lib.nixosSystem {
      inherit system;
      modules =
        [
          {
            system.stateVersion = lib.mkDefault host.stateVersion;
          }
        ]
        ++ self.lib.getHostModules "nixos" host;
      specialArgs = {};
    };

  flake.lib.mkDarwinConfiguration = system: host: target: let
    nixpkgs = self.lib.getInput target.pkgs;
  in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules =
        [
          {
            nixpkgs.source = nixpkgs;
            nixpkgs.flake.source = nixpkgs;
          }
          ({config, ...}: {
            system.stateVersion = mkDefault (
              if host.darwinStateVersion == null
              then config.system.maxStateVersion
              else host.darwinStateVersion
            );
          })
        ]
        ++ self.lib.getHostModules "darwin" host;
      specialArgs = {};
    };

  flake.lib.mkHomeConfiguration = system: host: target:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = (self.lib.getInput target.pkgs).legacyPackages.${system};
      modules =
        [
          {
            home.stateVersion = lib.mkDefault host.stateVersion;
            home.username = lib.mkDefault host.name;
            home.homeDirectory = lib.mkDefault (
              if builtins.match ".*-darwin" system != null
              then "/Users/${host.name}"
              else "/home/${host.name}"
            );
          }
        ]
        ++ self.lib.getHostModules "home" host;
      extraSpecialArgs = {};
    };
}
