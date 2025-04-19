{ fetchFromGitHub
, stdenv
, fuse3
, pkg-config
, squashfuse
, zstd
, zlib
, xz
, lz4
, lzo
, lib
}:

let
  src = fetchFromGitHub {
    owner = "AppImage";
    repo = "type2-runtime";
    rev = "2df896eb93b2c63664605cd531c19d09a4266894"; #https://github.com/AppImage/type2-runtime/commit/2df896eb93b2c63664605cd531c19d09a4266894
    sha256 = "0rg2alfb8fwld86gdhhdlm1jdmyw8scbjsyp00himwiz47vv3r5g";
    #hash = "sha256-0rg2alfb8fwld86gdhhdlm1jdmyw8scbjsyp00himwiz47vv3r5g";
    #nix-prefetch-url --unpack https://github.com/AppImage/type2-runtime/archive/${rev}.tar.gz
    # nix hash to-sri --type sha256 ${SHA}
  };

  fuse3' = fuse3.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      # this doesn't work -- causes fuse: failed to exec fusermount: Permission denied
      # "${src}/patches/libfuse/mount.c.diff"
    ];
  });

  squashfuse' = (squashfuse.override (
  lib.optionalAttrs (squashfuse ? override && squashfuse.override ? __functionArgs && squashfuse.override.__functionArgs ? fuse3) {
    fuse3 = fuse3';
  } // lib.optionalAttrs (squashfuse ? override && squashfuse.override ? __functionArgs && squashfuse.override.__functionArgs ? fuse) {
    fuse = fuse3';
  }
  )).overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cp *.h -t $out/include/squashfuse/
    '';
  });
in
stdenv.mkDerivation {
  pname = "appimage-type2-runtime";
  version = "unstable-2024-08-17";

  inherit src;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    fuse3'
    squashfuse'
    zstd
    zlib
    xz
    lz4
    lzo
  ];

  #patchPhase = ''
  #  sed -e '/sqfs_usage/s/);/, true\0/' -i src/runtime/runtime.c
  #'';

  configurePhase = ''
    $PKG_CONFIG --cflags fuse3 > cflags
  '';

  buildPhase = ''
    $CC src/runtime/runtime.c -o $out \
      -D_FILE_OFFSET_BITS=64 -DGIT_COMMIT='"0000000"' \
      $(cat cflags) \
      -std=gnu99 -Os -ffunction-sections -fdata-sections -Wl,--gc-sections -static -w \
      -lsquashfuse -lsquashfuse_ll -lfuse3 -lzstd -lz -llzma -llz4 -llzo2 \
      -T src/runtime/data_sections.ld

    # Add AppImage Type 2 Magic Bytes to runtime
    printf %b '\x41\x49\x02' > magic_bytes
    dd if=magic_bytes of=$out bs=1 count=3 seek=8 conv=notrunc status=none
  '';

  dontFixup = true;
}
