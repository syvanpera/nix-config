{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    vimdiffAlias = true;

#    extraConfig = ''
#      lua << EOF
#        ${builtins.readFile ./sane_defaults.lua}
#        ${builtins.readFile ./treesitter.lua}
#        ${builtins.readFile ./telescope.lua}
#        ${builtins.readFile ./lsp.lua}
#        ${builtins.readFile ./statusline.lua}
#      EOF
#    '';
  };
}
