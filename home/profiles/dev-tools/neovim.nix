{ inputs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;

    opts = {
      number = true;
    };

    colorschemes.catppuccin.enable = true;

    plugins = {
      web-devicons.enable = true;
      gitsigns.enable = true;
      neogit.enable = true;
      cmp.enable = true;
      conform-nvim.enable = true;
      lualine.enable = true;
      bufferline.enable = true;
      indent-blankline.enable = true;
      trouble.enable = true;

      mini.modules.bufremove = {};

      neo-tree = {
        enable = true;
        settings.window.position = "right";
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      treesitter = {
        enable = true;
        settings.ensure_installed = [
          "nix"
          "css"
          "toml"
          "json"
          "yaml"
          "bash"
          "markdown"
        ];
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          cssls.enable = true;
          taplo.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          marksman.enable = true;
        };
      };
    };
  };
}
