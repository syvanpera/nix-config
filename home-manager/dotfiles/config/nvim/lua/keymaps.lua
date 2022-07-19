local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Insert --
-- Press jk/kj fast to enter
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Visual --
-- keymap("v", "p", '"_dP', opts)

-- Stay in indent mode
-- keymap("v", "<", "<gv", opts)
-- keymap("v", ">", ">gv", opts)

-- Visual Block --
-- Move text up and down
-- keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

keymap("n", "<M-s>", ":w<cr>", opts)

-- Buffer operations
keymap("n", "<Leader>bd", "<cmd>bdel<cr>", opts)
keymap("n", "<Leader>bn", "<cmd>bnext<cr>", opts)
keymap("n", "<Leader>bp", "<cmd>bprev<cr>", opts)
keymap("n", "<Leader>bb", "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)

-- File operations
keymap("n", "<Leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
keymap("n", "<Leader>fp", "<cmd>lua require('telescope.builtin').find_files({ search_dirs = { '~/.config/nvim' } })<cr>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<cr>", opts)
keymap("n", "<Leader>gb", "<cmd>lua require('telescope.builtin').git_branches()<cr>", opts)

-- File tree
keymap("n", "<M-e>", ":NvimTreeToggle<cr>", opts)

-- Telescope
-- keymap("n", "<A-F>", "<cmd>lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({}))<cr>", opts)
keymap("n", "<A-F>", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
keymap("n", "<M-r>", "<cmd>lua require('telescope.builtin').treesitter()<cr>", opts)

keymap("n", "<M-x>", "<cmd>lua require('telescope.builtin').commands()<cr>", opts)
