local packer = require("util.packer")

local config = {
  profile = {
    enable = true,
    threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
  },
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
  },
  opt_default = true,
  -- list of plugins that should be taken from ~/projects
  -- this is NOT packer functionality!
  local_plugins = {},
}

local function plugins(use)
  -- Packer can manage itself as an optional plugin
  use({ "wbthomason/packer.nvim" })

  -- Theme: color schemes
  use({
    "folke/tokyonight.nvim",
    opt = false,
    -- event = "VimEnter",
    config = [[require("config.theme")]],
  })

  -- Theme: icons
  use({
    "kyazdani42/nvim-web-devicons",
    module = "nvim-web-devicons",
    config = [[require("nvim-web-devicons").setup({ default = true })]],
  })

  use({
    "glepnir/dashboard-nvim",
    opt = false,
    config = [[require("config.dashboard")]],
  })

  use({ "nvim-lua/plenary.nvim", module = "plenary" })

  use({ "christoomey/vim-tmux-navigator", opt = false })

  use({
    "kyazdani42/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeClose" },
    config = [[require("config.tree")]],
  })

  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    event = "BufRead",
    opt = false,
    requires = {
      { "nvim-treesitter/playground", cmd = "TSHighlightCapturesUnderCursor" },
      "nvim-treesitter/nvim-treesitter-textobjects",
      "RRethy/nvim-treesitter-textsubjects",
    },
    config = [[require("config.treesitter")]],
  })

  use({
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    wants = "nvim-treesitter",
    module = "nvim-gps",
    config = [[require("nvim-gps").setup({ separator = " " })]],
  })

  use({
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    wants = "nvim-web-devicons",
    config = [[require("config.lualine")]],
  })

  use({
    "numToStr/Comment.nvim",
    keys = { "gc", "gcc", "gbc" },
    config = [[require("config.comments")]],
  })

  use({
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = [[require("config.notify")]],
  })

  use({
    "windwp/nvim-autopairs",
    opt = false,
    config = [[require("config.autopairs")]],
  })

  -- Git Gutter
  use({
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    wants = "plenary.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = [[require("config.gitsigns")]],
  })

  -- Fuzzy finder
  use({
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    module = "telescope",
    keys = { "<leader><space>", "<leader>fz", "<leader>pp" },
    wants = {
      "plenary.nvim",
    },
    requires = {
      "nvim-lua/plenary.nvim",
    },
    config = [[require("config.telescope")]],
  })

  use({
    "akinsho/nvim-toggleterm.lua",
    opt = false,
    config = [[require("config.terminal")]],
  })

  -- Indent Guides and rainbow brackets
  use({
    "lukas-reineke/indent-blankline.nvim",
    opt = false,
    event = "BufReadPre",
    config = [[require("config.blankline")]],
  })

  -- Tabs
  use({
    "akinsho/nvim-bufferline.lua",
    event = "BufReadPre",
    wants = "nvim-web-devicons",
    config = [[require("config.bufferline")]],
  })

  use({
    "LnL7/vim-nix",
    opt = false,
  })

end

return packer.setup(config, plugins)
