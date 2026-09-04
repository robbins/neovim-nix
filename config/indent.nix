{ lib, ... }:
{
  opts = {
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
  };
  autoCmd = let
    indents = {
      "4" = [ "kotlin" "java" ];
    };
  in lib.mapAttrsToList (indent: patterns: { event = [ "FileType" ]; command = "setlocal shiftwidth=${indent} tabstop=${indent}"; pattern = patterns; }) indents;
}
