{
  lsp = {
    servers = {
      clangd = {
        enable = true;
        packageFallback = true; # Allow devshell to override
      };
    };
  };
}
