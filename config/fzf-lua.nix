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
      "<leader>fg" = {
        action = "live_grep_native";
        options.desc = "Fzf Live Grep";
      };
      "<leader>ff" = {
        action = "files";
        options.desc = "Fzf Find Files";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Fzf Find Buffer";
      };
    };
  };
}
