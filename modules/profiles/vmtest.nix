{self, ...}:
with self.lib; {
  flake.profiles.generic.vmtest = mkProfile "vmtest" ({...}: {
    profile = {
      user = {
        username = "vmtest";
        fullname = "fullname";
        email = "vmtest@gmail.com";
      };
    };
  });

  flake.profiles.nixos.vmtest = mkProfile "vmtest" ({
    pkgs,
    config,
    ...
  }: {
    environment.variables = {
      PROFILE = config.profile.user.username;
    };
    environment.systemPackages = with pkgs; [
      hello
    ];
  });
}
