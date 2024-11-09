{ runCommand,
  pkgsStatic,
  system,
  fetchurl
}:
let 
  arch = {
    "x86_64-linux" = "x86_64";
    "aarch64-linux" = "aarch64";
  }.${system} or (throw "Unsupported system: ${system}");
 #https://github.com/pkgforge/nix-appimage/releases/tag/bwrap
  remoteBwrap = fetchurl {
    url = "https://github.com/pkgforge/nix-appimage/releases/download/bwrap/bwrap-${arch}";
    sha256 = if arch == "x86_64" then "fdfd31dd4540d16d8ad2e77612ce8b683f5d115c6b4ab7894e88a12bc437f0e6"
              else if arch == "aarch64" then "5d58302e79ddea0705f866afb018be83000e95496d145db72febea9ec4477ac3"
              else throw "Unsupported architecture: ${arch}";
  };
  #Patched to allow nested bwraps for fun and profit
  remoteBwrapPatched = fetchurl {
    url = "https://github.com/pkgforge/nix-appimage/releases/download/bwrap/bwrap-patched-${arch}";
    sha256 = if arch == "x86_64" then "6859d8b0eaa5dbc63ce0b07f12355df528456eacf462361ad01b9defe6709fc3"
              else if arch == "aarch64" then "0a699ed6a8cc33da1c5c074990aed3561631f877688ced742f7a13d880096ddc"
              else throw "Unsupported architecture: ${arch}";
  };
in
runCommand "AppRun" { } ''
  mkdir $out
  cp ${./AppRun.sh} $out/AppRun
  chmod +x $out/AppRun
  cp ${pkgsStatic.bubblewrap}/bin/bwrap $out/bwrap
  chmod +x $out/bwrap
  cp ${remoteBwrap} $out/bwrap-bin
  chmod +x $out/bwrap-bin
  cp ${remoteBwrapPatched} $out/bwrap-patched
  chmod +x $out/bwrap-patched
''