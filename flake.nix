{
  description = "Anki decks hosted on patrickstevens.co.uk";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    anki-compiler.url = "github:Smaug123/anki-dotnet";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    anki-compiler,
  }: let
    commit = self.shortRev or "dirty";
    date = self.lastModifiedDate or self.lastModified or "19700101";
    version = "1.0.0+${builtins.substring 0 8 date}.${commit}";
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in let
      createShellScript = name: contents:
        pkgs.stdenv.mkDerivation {
          __contentAddressed = true;
          pname = name;
          version = "0.1.0";
          src = contents;

          buildInputs = [
            pkgs.shellcheck
          ];

          phases = ["configurePhase" "buildPhase" "installPhase"];

          configurePhase = ''
            ${pkgs.shellcheck}/bin/shellcheck "${contents}"
          '';

          buildPhase = ''
            cp "${contents}" run.sh
            patchShebangs run.sh
            sed -i 's_"/bin/bash"_"${pkgs.bash}/bin/bash"_' run.sh
            sed -i 's_"/bin/sh"_"${pkgs.bash}/bin/bash"_' run.sh
          '';

          installPhase = ''
            mkdir -p $out
            mv run.sh $out/run.sh
          '';
        };
    in let
      buildAnki = createShellScript "anki" ./build.sh;
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        __contentAddressed = true;
        inherit version;
        pname = "patrickstevens.co.uk-anki";
        src = ./.;
        buildInputs = [];
        installPhase = ''
          ${buildAnki}/run.sh . "${anki-compiler.packages.${system}.default}/bin/AnkiStatic" "$out"
        '';
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.alejandra pkgs.shellcheck];
      };
    });
}
