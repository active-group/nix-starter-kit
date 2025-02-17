let
  mac-app-util-src = builtins.fetchTarball {
    url = "https://github.com/hraban/mac-app-util/archive/548672d0cb661ce11d08ee8bde92b87d2a75c872.tar.gz";
    sha256 = "1w80vjcnaysjlzxsp3v4pxq4yswbjvxs8ann2bk0m7rkjljnzz6m";
  };
  mac-app-util = import mac-app-util-src {};
in
  mac-app-util.homeManagerModules.default
