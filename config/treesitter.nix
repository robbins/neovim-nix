{
  plugins.treesitter = {
    enable = true;
    highlight.enable = false;
    indent.enable = true;
    folding.enable = true;
  };
  opts = {
    foldenable = false;
  };
  autoCmd = [
    {
      # Open buffers unfolded and sets foldlevel to max for buffer
      event = [ "BufWinEnter" ];
      command = "silent! normal! zR";
    }
  ];
}
