{
  description = "sigbak for allyourcodebase";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls?ref=0.13.0";
  };

  outputs = inputs:
    let
      inherit (inputs) nixpkgs zig-overlay flake-utils zls;
      systems = [ "x86_64-linux" ];
      ignoringVulns = x: x // { meta = (x.meta // { knownVulnerabilities = []; }); };
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        zig = zig-overlay.packages.${system}."0.13.0";
        zls_pkg = zls.packages.${system}.default;
        pkgconfig = pkgs.pkg-config;
        gcc = pkgs.gcc;
        gdb = pkgs.gdb;
        dwarf = pkgs.libdwarf;
        glibc = pkgs.glibc;
        openssl = pkgs.openssl;
        sqlite = pkgs.sqlite;
        protobufc = pkgs.protobufc;
      in
      {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = with pkgs; [ gcc glibc pkg-config openssl sqlite protobufc zig ];
          buildInputs = with pkgs; [ zls_pkg gdb dwarf ];
          shellHook = with pkgs.lib; ''
            export LD_LIBRARY_PATH="${makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
          '';
        };
      }
    );
}
