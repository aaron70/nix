{
  self,
  config,
  lib,
  ...
}:
with lib; let
  anvilFeatures = config.anvil.features;
in {
  flake.lib.getFeature = parentType: parentName: name:
    if anvilFeatures ? ${name}
    then let
      feature = anvilFeatures.${name};
      featureName = self.lib.getPropertyOrDefault feature "name" name;
    in 
      if feature.name == null
      then feature // {name = featureName;}
      else feature
    else throw "Anvil: ${parentType} '${parentName}' declares a not found feature '${name}'. Did you forget to set anvil.features.${name}?";

  flake.lib.getFeaturesModules = accumulator: platform: parentType: parent: ctx: features: let
    acc = accumulator // {features = accumulator.features or {};};
  in
    foldl
    (
      acc: refkey: let
        name = if isString refkey then refkey else refkey.ref;
        variant =
          if isString refkey
          then null
          else self.lib.getPropertyOrDefault refkey "variant" null;
        key = "${name}${if variant == null then "" else "@${variant}"}";
        visited = acc.features ? "${key}";
        feature = self.lib.resolveRefKey refkey (self.lib.getFeature parentType parent.name);
        newAcc =
          if visited
          then acc
          else recursiveUpdate acc {features = {"${key}" = (self.lib.withContext (ctx//{inherit feature;}) (self.lib.getPropertyOrDefault feature platform {}));};};
      in
        if visited
        then newAcc
        else
          self.lib.getProgramsModules
          (self.lib.getFeaturesModules newAcc platform parentType parent ctx feature.features)
          platform parentType parent ctx feature.programs
    )
    acc
    features;
}
