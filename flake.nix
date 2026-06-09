{
  description = "My patched dwm";

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
        enableParallelBuilding = true;

        nativeBuildInputs = with pkgs; [
          pkg-config
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
          runHook preBuild
          make clean
          make
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          cp dwm $out/bin/

          mkdir -p $out/share/man/man1
          if ls *.1 >/dev/null 2>&1; then
            cp *.1 $out/share/man/man1/
          fi

          mkdir -p $out/share/doc/dwm
          for f in LICENSE README README.md README.org; do
            if [ -f "$f" ]; then
              cp "$f" $out/share/doc/dwm/
            fi
          done

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Custom patched DWM";
          homepage = "https://dwm.suckless.org/";
          license = licenses.mit;
          platforms = platforms.linux;
        };
      };
    });

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          gcc
          gnumake
          pkg-config

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
      };
    });

    overlays.default = final: prev: {
      dwm = self.packages.${prev.system}.default;
    };
  };
}
