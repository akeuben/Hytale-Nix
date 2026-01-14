{
    description = "Official Hytale Launcher packaged for Nix";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
    in {
        packages.${system}.hytale-launcher = pkgs.callPackage ./linux_amd64.nix {};
        defaultPackage.${system} = self.packages.${system}.hytale-launcher;
    };
}

