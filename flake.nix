{
  description = "My patched DWM";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      default = pkgs.stdenv.mkDerivation {
        pname = "dwm";
        version = "git";

        src = self;

        strictDeps = true;
        dontConfigure = true;

        nativeBuildInputs = [
          pkgs.pkg-config
        ];

        buildInputs = with pkgs; [
          libX11
          libXft
          libXinerama
          libxcb
          xcbutil
          libXi
          libXfixes

          fontconfig
          freetype
          harfbuzz
        ];

        buildPhase = ''
          make clean
          make
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp dwm $out/bin/

          mkdir -p $out/share/man/man1
          cp *.1 $out/share/man/man1/ || true
        '';
      };
    });

    overlays.default = final: prev: {
      dwm-custom = self.packages.${prev.system}.default;
    };
  };
}
