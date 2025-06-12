pkgs:

let
  mac-app-util-src = builtins.fetchTarball {
    url = "https://github.com/hraban/mac-app-util/archive/341ede93f290df7957047682482c298e47291b4d.tar.gz";
    sha256 = "1f06xpjy82ql5i7va7z0ii97hjgsh31il42ifnnrndyd5bc3ycv9";
  };
  mac-app-util = import mac-app-util-src { inherit pkgs; };
in
mac-app-util.homeManagerModules.default
