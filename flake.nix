{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";

    chariot.url = "github:chariot-build/chariot";
    # chariot.url = "/persist/user/projects/chariot";
    chariot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        commonPackages = with pkgs; [
          inputs.chariot.packages.${system}.default

          wget # Required by Chariot
          libarchive # Required by Chariot

          python3 # Used heavily by tools

          llvmPackages_22.clang-tools # clang-format & clang-tidy
          tree
          gdb
          qemu_full
        ];
      in
      {
        formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
        devShells.default = pkgs.mkShell {
          shellHook = "export NIX_SHELL_NAME='lunar (chariot v3)'";
          nativeBuildInputs = commonPackages;
        };
      }
    );
}
