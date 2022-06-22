{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {}
}:

let

  inherit (pkgs) cmake stdenv;

  # TODO: Maybe its possible to parse those from the toolchain file?
  cross-flags = pkgs.lib.concatStringsSep " " [
  "-nostdinc"
  "-mno-red-zone"
  "-m64"
  "-march=westmere"
  "-mno-3dnow"
  "-mno-mmx"
  "-mno-sse"
  ];

  systemLib =  rec {
    libc = stdenv.mkDerivation {
      name = "liblibc";
      nativeBuildInputs = [ cmake ];
      src = ./libc;
    };
  };

  crossCompileDrv = drv: drv.overrideAttrs (
    old: {
      preConfigure = ''
        cmakeFlagsArray=(
          $cmakeFlagsArray
          "-DCMAKE_CXX_FLAGS=${cross-flags}"
          "-DCMAKE_SYSTEM_NAME=x86_64_Baremetal"
          )
      '';
      buildInputs = [ systemLib.libc ] ++ (builtins.map crossCompileDrv (old.buildInputs or []));
    });

in
rec {
  recurseForDerivations = true;

  inherit systemLib;

  lib = rec {
    recurseForDerivations = true;
    a = stdenv.mkDerivation {
      name = "liba";
      buildInputs = [ c d ];
      nativeBuildInputs = [ cmake ];
      src = ./a;
    };
    b = stdenv.mkDerivation {
      name = "libb";
      nativeBuildInputs = [ cmake ];
      src = ./b;
    };
    c = stdenv.mkDerivation {
      name = "libc";
      nativeBuildInputs = [ cmake ];
      src = ./c;
    };
    d = stdenv.mkDerivation {
      name = "libd";
      nativeBuildInputs = [ cmake ];
      src = ./d;
    };
  };

  # Native Linux app
  myapp = stdenv.mkDerivation {
    name = "myapp";

    # Need to disable format security otherwise the compiler complains.
    preConfigure = ''
      cmakeFlagsArray=(
        $cmakeFlagsArray
        "-DCMAKE_CXX_FLAGS=-Wno-format-security"
        )
    '';

    buildInputs = with lib; [ a b c d ];
    nativeBuildInputs = [ cmake ];
    src = ./app;
  };

  # Non-std libs and app with custom libc
  lib-cross = pkgs.lib.mapAttrs (name: val: if (pkgs.lib.isDerivation val) then crossCompileDrv val else val) lib;
  myapp-cross = crossCompileDrv myapp;
}
