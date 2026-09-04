{ config, ... }:
{
  clipboard = {
    register = "unnamedplus";
    providers = {
      wl-copy.enable = config.waylandSupport;
    };
  };
}
