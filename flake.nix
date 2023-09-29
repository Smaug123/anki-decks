{
  description = "Anki decks hosted on patrickstevens.co.uk";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    anki-compiler.url = "github:Smaug123/anki-dotnet";
    scripts.url = "github:Smaug123/flake-shell-script";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    anki-compiler,
    scripts,
  }: let
    commit = self.shortRev or "dirty";
    date = self.lastModifiedDate or self.lastModified or "19700101";
    version = "1.0.0+${builtins.substring 0 8 date}.${commit}";
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        __contentAddressed = true;
        inherit version;
        pname = "patrickstevens.co.uk-anki";
        src = ./.;
        buildInputs = [];
        installPhase = ''
          ${scripts.lib.createShellScript pkgs "anki" ./build.sh}/run.sh . "${anki-compiler.packages.${system}.default}/bin/AnkiStatic" "$out"
        '';
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.alejandra pkgs.shellcheck];
      };
    });
}
