{ lib, ... }:
rec {
  toHex =
    n:
    let
      hex = "0123456789abcdef";
      hi = builtins.div n 16;
      lo = lib.mod n 16;
    in
    "${builtins.substring hi 1 hex}${builtins.substring lo 1 hex}";

  grayscale =
    i: len:
    let
      # avoid division by zero if list has 1 element
      t = if len <= 1 then 0 else i * 255 / (len - 1);
      v = builtins.floor t;
      h = toHex v;
    in
    "#${h}${h}${h}";

  mergeAttrsIgnoringNulls =
    list:
    lib.foldl' lib.recursiveUpdate { } (map (attrs: lib.filterAttrs (_: v: v != null) attrs) list);
}
