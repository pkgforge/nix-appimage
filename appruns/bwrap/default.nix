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
    sha256 = if arch == "x86_64" then "64ce8bae20ba27fdbf832eb830e06394a0eb77bc15b588e9b66a40a17b23affb"
              else if arch == "aarch64" then "aaf6282c278a23f8492a57e8b484867ca609220f949d89686ab90713c3dfead5"
              else throw "Unsupported architecture: ${arch}";
  };
  #Patched to allow nested bwraps for fun and profit
  remoteBwrapPatched = fetchurl {
    url = "https://github.com/pkgforge/nix-appimage/releases/download/bwrap/bwrap-patched-${arch}";
    sha256 = if arch == "x86_64" then "6af6dc32bcbcec50ce79217163f5bacda090afaf10a8660d6ef1cca2240d714f"
              else if arch == "aarch64" then "9a0c21cd3f64f0f6869bb5ba423692e2428b23be18acbf90ce8fd921f02fefc6"
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