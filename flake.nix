{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";

    chariot.url = "github:elysium-os/chariot/4811d772d782ff74387d529c89b67d2d83672369";
    chariot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        commonPackages = with pkgs; [
          inputs.chariot.defaultPackage.${system}

          wget # Required by Chariot
          libarchive # Required by Chariot

          python3 # Used heavily by tools

          llvmPackages_22.clang-tools # clang-format & clang-tidy

          gdb
          qemu_full
        ];
      in
      {
        formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
        devShells.default = pkgs.mkShell {
          shellHook = "export NIX_SHELL_NAME='lunar'";
          nativeBuildInputs = commonPackages;
        };
      }
    );
}
