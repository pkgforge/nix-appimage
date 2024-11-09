- #### About
> This is a hard fork of the original [ralismark/nix-appimage](https://github.com/ralismark/nix-appimage) with following Changes:
> - Use [BubbleWrap](https://github.com/containers/bubblewrap) & [Static Binaries](https://github.com/Azathothas/Toolpacks)
> - Use [Universal AppRun](https://github.com/pkgforge/pkgcache/blob/main/appruns/bwrap/AppRun.sh)
> - And other changes meant to make porting [NixAppImages](https://github.com/pkgforge/pkgcache/blob/main/Docs/NIXAPPIMAGES.md) for [PkgForge/PkgCache](https://github.com/pkgforge/pkgcache) easier

- #### Use
```bash
!#${APP} --> https://search.nixos.org/packages
nix bundle --bundler "github:pkgforge/nix-appimage?ref=main" "nixpkgs#${APP}" --out-link "./${APP}.AppImage" --log-format bar-with-logs 
```
