{...}: {
  anvil.features.ollama = {
    nixos = {pkgs, ...}: {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-vulokan;
      };
    };

    variants = {
      nvidia = {
        nixos = {pkgs, ...}: {
          services.ollama = {
            enable = true;
            package = pkgs.ollama-cuda;
          };
        };
      };
    };
  };
}
