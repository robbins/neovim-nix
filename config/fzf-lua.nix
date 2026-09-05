{ lib, ... }:
{
  plugins.fzf-lua = {
# TODO: configure more
    enable = true;
    settings = {
      # TODO: cfg.profile exists but not updated to accept new profiles - PR?
      __unkeyed_profile = lib.mkForce "ivy";
    };
    keymaps = {
      "<leader>fg" = "live_grep_native";
      "<leader>ff" = "files";
      "<leader>fb" = "buffers";
    };
  };
}
