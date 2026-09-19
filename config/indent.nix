{ lib, ... }:
{
  opts = {
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    autoindent = true;
    smartindent = true;
  };
  autoCmd =
    let
      indents = {
        "4" = [
          "kotlin"
          "java"
        ];
        "2" = [
          # neovim smartindent is horrible, and TS gives us 4
          "python"
        ];
      };
    in
    lib.mapAttrsToList (indent: patterns: {
      event = [ "FileType" ];
      command = "setlocal shiftwidth=${indent} tabstop=${indent}";
      pattern = patterns;
    }) indents;
}
