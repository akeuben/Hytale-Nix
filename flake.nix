{
    description = "Hytale Launcher packaged for nixos";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
    in {
        packages.${system}.hytale-launcher = import ./linux_amd64.nix { inherit pkgs; };

        defaultPackage.${system} = self.packages.${system}.hytale-launcher;
    };
}

