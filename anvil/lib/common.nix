{self, lib, ...}:
with lib; {
  flake.lib.withContext = ctx: mod: let
    unwrapPath = m:
      if isPath m
      then import m
      else m;
    unwrap = m':
      if
        isAttrs m'
        && isList (m'.imports or null)
        && length m'.imports == 1
        && all (k: k == "imports" || k == "_file" || k == "key") (attrNames m')
      then head m'.imports
      else m';
    unwrapMod = m: unwrapPath (unwrap (unwrap (unwrapPath m)));
    wrap = fragment:
      if isFunction fragment
      then
        {
          config,
          lib,
          pkgs,
          ...
        } @ args:
          fragment (ctx // removeAttrs args ["host" "user" "system"])
      else fragment;
  in
    if isList mod
    then {imports = map (m: self.lib.withContext ctx (unwrapMod m)) mod;}
    else wrap (unwrapMod mod);

  flake.lib.getPropertyOrDefault = attr: property: default:
    if attr ? "${property}" && attr.${property} != null
    then attr.${property}
    else default;

  flake.lib.getVariant = entity: variant: let
    unnamed = self.lib.getPropertyOrDefault entity "name" "<unnamed>";
  in
    if entity ? variants && entity.variants ? "${variant}"
    then let
        v = entity.variants.${variant};
      in
        if (v.name or null) == null
        then v // {name = variant;}
        else v
    else throw "Anvil: Entity '${unnamed}' doesn't have variant '${variant}'.";

  flake.lib.resolveRefKey = refkey: resolver: let
    name = if isString refkey 
      then refkey 
      else (self.lib.getPropertyOrDefault refkey "ref" null);
    entity = resolver name;
    fragments = ["nixos" "darwin" "home"];
  in if isString refkey
    then entity
    else let
        variant = self.lib.getPropertyOrDefault refkey "variant" null;
        merge = self.lib.getPropertyOrDefault refkey "merge" {};
        override = self.lib.getPropertyOrDefault refkey "override" {};
        base = entity // override;
        mergeFragments = filterAttrs (k: _: elem k fragments) merge;
        mergeScalars = removeAttrs merge fragments;
        composeFragment = key: fragment: let
            baseFragment = base.${key} or null;
          in
            if baseFragment == null
            then fragment
            else if fragment == null
            then baseFragment
            else [baseFragment fragment];
        mergedFragments = mapAttrs composeFragment mergeFragments;
        mergedEntity = (recursiveUpdate base mergeScalars) // mergedFragments;
      in if variant != null  && mergedEntity ? variants
        then self.lib.getVariant mergedEntity variant
        else mergedEntity;

}
