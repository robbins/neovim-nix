{
  plugins.blink-cmp = {
    enable = true;
    settings = {
      completion = {
        ghost_text.enabled = true;
        list = {
          selection = {
            auto_insert = false;
          };
        };
      };
      keymap = {
        preset = "enter";
        "<Right>" = [ "accept" "fallback" ];
      };
    };
  };
}
