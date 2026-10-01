-- ~/.config/nvim/init.lua
-- Single-file Neovim config: options + keymaps + plugins. Kept intentionally minimal.

--------------------------------------------------------------------------------
-- Leader (must be set BEFORE plugins load)
--------------------------------------------------------------------------------
vim.g.mapleader = ","
vim.g.maplocalleader = ","

--------------------------------------------------------------------------------
-- Options (vim.opt = `set`)
--------------------------------------------------------------------------------
local opt = vim.opt

opt.number = true             -- absolute line numbers
opt.relativenumber = false    -- no relative numbers
opt.mouse = "a"               -- mouse in all modes
opt.clipboard = "unnamedplus" -- use system clipboard
opt.ignorecase = true         -- case-insensitive search...
opt.smartcase = true          -- ...unless capital typed
opt.termguicolors = true      -- 24-bit color (needed by modern themes)
opt.signcolumn = "yes"        -- always show sign column (no text shift)
opt.undofile = true           -- persistent undo across sessions
opt.scrolloff = 8             -- keep 8 lines above/below cursor

-- Indent
opt.expandtab = true          -- tabs -> spaces
opt.shiftwidth = 4            -- indent width
opt.tabstop = 4               -- tab display width
opt.smartindent = true

opt.splitright = true         -- vsplit opens right
opt.splitbelow = true         -- split opens below

--------------------------------------------------------------------------------
-- Keymaps (vim.keymap.set(mode, lhs, rhs, opts))
--------------------------------------------------------------------------------
local map = vim.keymap.set

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Clear search highlight
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Down window" })
map("n", "<C-k>", "<C-w>k", { desc = "Up window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })

-- Fzf-lua: Ctrl+P to find files (wraps Go fzf binary)
map("n", "<C-p>", function() require("fzf-lua").files() end, { desc = "Find files (Ctrl+P)" })
map("n", "<C-f>", function() require("fzf-lua").live_grep() end, { desc = "Live grep (Ctrl+F)" })

-- vim-easy-align (visual mode)
map("x", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })

--------------------------------------------------------------------------------
-- Plugins (vim.pack — native manager, Neovim 0.12+)
--------------------------------------------------------------------------------
local gh = function(repo) return "https://github.com/" .. repo end

-- Installs on first run (blocking), then loads all listed plugins.
vim.pack.add({
  -- Fuzzy finder
  { src = gh("ibhagwan/fzf-lua") },

  -- Editing helpers
  { src = gh("jiangmiao/auto-pairs") },      -- auto close brackets
  { src = gh("junegunn/vim-easy-align") },

  -- Colorscheme
  { src = gh("rakr/vim-one") },
})

vim.cmd.colorscheme("one")
