local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup( {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-g>"] = actions.close,

        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = {
        ["<esc>"] = actions.close,
        ["<C-g>"] = actions.close,
      }
    }
  }
})

