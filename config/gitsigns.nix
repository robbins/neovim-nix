{
  plugins.gitsigns = {
    enable = true;
    settings = {
      current_line_blame = true;
      current_line_blame_formatter = "<summary> - <author_time:%Y>  ";
      current_line_blame_opts = {
        virt_text_pos = "right_align";
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>Gitsigns blame_line<CR>";
    }
    {
      mode = "n";
      key = "<leader>gB";
      action = "<cmd>Gitsigns blame<CR>";
    }
    {
      mode = "n";
      key = "]h";
      action = "<cmd>Gitsigns nav_hunk prev<CR>";
    }
    {
      mode = "n";
      key = "]h";
      action = "<cmd>Gitsigns nav_hunk prev<CR>";
    }
    {
      mode = "n";
      key = "<leader>hs";
      action = "<cmd>Gitsigns stage_hunk<CR>";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action = "<cmd>Gitsigns reset_hunk<CR>";
    }
    {
      mode = "n";
      key = "<leader>hR";
      action = "<cmd>Gitsigns reset_buffer<CR>";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = "<cmd>Gitsigns preview_hunk_inline<CR>";
    }
  ];
}
