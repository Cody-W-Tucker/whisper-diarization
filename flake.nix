{
  description = "OpenAI-compatible WhisperX speaker diarization service";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      mkPackage = pkgs: python:
        pkgs.writeShellApplication {
          name = "whisper-diarization";
          runtimeInputs = [ python ];
          text = ''
            export PYTHONPATH=${self}/src''${PYTHONPATH:+:$PYTHONPATH}
            exec ${python}/bin/python3 -m diarization.server "$@"
          '';
        };
      defaultPython = pkgs:
        pkgs.python313.withPackages (ps: with ps; [
          fastapi
          python-multipart
          torch
          uvicorn
          whisperx
        ]);
    in {
      lib = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          mkPackage = { python ? defaultPython pkgs }:
            mkPackage pkgs python;
        });

      packages = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
            app = mkPackage pkgs (defaultPython pkgs);
        in {
          default = app;
          whisper-diarization = app;
        });

      devShells = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShellNoCC {
            packages = [ (defaultPython pkgs) ];
          };
        });
    };
}
