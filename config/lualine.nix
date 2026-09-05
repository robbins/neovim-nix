{
  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_a = [
          "mode"
        ];
        lualine_b = [
          {
            __unkeyed-1 = "diff";
            separator = {
              right = "";
            };
          }
          {
            __unkeyed-1 = "branch";
          }
        ];
        lualine_c = [
          {
            __unkeyed-1 = "filename";
            path = 4;
            symbols = {
              readonly = "[RO]";
              unnamed = "[None]";
            };
          }
          "diagnostics"
          "lsp_status"
        ];
        lualine_x = [
          "filetype"
        ];
        lualine_y = [
          {
            __unkeyed-1 = "encoding";
            separator.right = "";
          }
          {
            __unkeyed-1 = "fileformat";
            symbols = {
              unix = "LF";
              win = "CRLF";
              mac = "LF"; # macOS < 10.0 is CR
            };
            padding = 0;
          }
        ];
        lualine_z = [
          {
            __unkeyed-1 = "progress";
            padding = 0;
          }
          {
            __unkeyed-1 = "location";
            padding = 0;
          }
        ];
      };
    };
  };
}
