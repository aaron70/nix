{...}: {
  anvil.features.amd = {
    features = [
      "graphics"
    ];
    nixos = {config, ...}: {
      services.xserver.videoDrivers = ["amdgpu"];
    };
  };
}
