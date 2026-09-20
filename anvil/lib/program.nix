{
  self,
  config,
  lib,
  ...
}:
with lib; let
  anvilPrograms = config.anvil.programs;
in {
  flake.lib.getProgram = parentType: parentName: name:
    if anvilPrograms ? ${name}
    then let
      program = anvilPrograms.${name};
      programName = self.lib.getPropertyOrDefault program "name" name;
    in
      if program.name == null
      then program // {name = programName;}
      else program
    else throw "Anvil: ${parentType} '${parentName}' declares a not found program '${name}'. Did you forget to set anvil.programs.${name}?";

  flake.lib.getProgramsList = entity: ctx:
    if isFunction entity.programs
    then entity.programs ctx
    else entity.programs;

  flake.lib.getProgramsModules = accumulator: platform: parentType: parent: ctx: programs: let
    acc = accumulator // {programs = accumulator.programs or {};};
  in
    foldl
    (
      acc: refkey: let
        name =
          if isString refkey
          then refkey
          else refkey.ref;
        variant =
          if isString refkey
          then null
          else self.lib.getPropertyOrDefault refkey "variant" null;
        key = "${name}${
          if variant == null
          then ""
          else "@${variant}"
        }";
        visited = acc.programs ? "${key}";
        program = self.lib.resolveRefKey refkey (self.lib.getProgram parentType parent.name);
        localCtx = ctx // {inherit program;};
        childrenPrograms = self.lib.getProgramsList program localCtx;
        childrenFeatures = self.lib.getFeaturesList program localCtx;
        newAcc =
          if visited
          then acc
          else recursiveUpdate acc {programs = {"${key}" = self.lib.withContext localCtx (self.lib.getPropertyOrDefault program platform {});};};
      in
        if visited
        then newAcc
        else
          self.lib.getFeaturesModules
          (self.lib.getProgramsModules newAcc platform parentType parent ctx childrenPrograms)
          platform
          parentType
          parent
          ctx
          childrenFeatures
    )
    acc
    programs;
}
