-- ~/.config/nvim/init.lua
-- Single-file Neovim config: options + keymaps + plugins (lazy.nvim).

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

-- Neo-tree toggle (reveals current file in tree)
map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "File tree" })

-- Neogit (Magit-like git TUI)
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

-- Fzf-lua: Ctrl+P to find files (faster than Telescope, wraps Go fzf binary)
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
  -- File tree (neo-tree + its deps)
  { src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") },
  { src = gh("MunifTanjim/nui.nvim") },
  { src = gh("nvim-tree/nvim-web-devicons") }, -- icons (needs a Nerd Font)

  -- Fuzzy finder (plenary is required by neogit)
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("ibhagwan/fzf-lua") },

  -- Statusline
  { src = gh("vim-airline/vim-airline") },
  { src = gh("vim-airline/vim-airline-themes") },

  -- Git TUI (Magit-like: stage, unstage, commit, diff, etc.)
  { src = gh("NeogitOrg/neogit") },

  -- Editing helpers
  { src = gh("jiangmiao/auto-pairs") },      -- auto close brackets
  { src = gh("Yggdroot/indentLine") },       -- indent guides
  { src = gh("junegunn/vim-easy-align") },
  { src = gh("rhysd/accelerated-jk") },      -- faster j/k

  -- Syntax/structure: treesitter (+ semantic text objects)
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "master" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects") },

  -- Completion (uses Lua fuzzy fallback when Rust/cargo absent)
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1") },

  -- Colorschemes
  { src = gh("mhartington/oceanic-next") },
  { src = gh("NLKNguyen/papercolor-theme") },
  { src = gh("junegunn/seoul256.vim") },
  { src = gh("rakr/vim-one") },
})

--------------------------------------------------------------------------------
-- Plugin setup (runs after vim.pack.add — plugins are loaded here)
--------------------------------------------------------------------------------
-- Git TUI (Magit-like)
require("neogit").setup({})

-- File tree
require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    follow_current_file = { enabled = true }, -- highlight open file
    use_libuv_file_watcher = true,            -- auto-refresh on fs changes
  },
})

-- Treesitter: precise highlight, indent, and semantic text objects.
require("nvim-treesitter.configs").setup({
  ensure_installed = { "python", "c", "cpp", "bash", "lua", "vim", "vimdoc" },
  auto_install = true,             -- install parser when opening new filetype
  highlight = { enable = true },
  indent = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer", ["if"] = "@function.inner",
        ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",["ia"] = "@parameter.inner",
      },
    },
  },
})

-- Completion (blink.cmp).
require("blink.cmp").setup({
  keymap = { preset = "default" }, -- <C-space> open, <C-n>/<C-p> select, <CR> accept
  fuzzy = { implementation = "prefer_rust_with_warning" }, -- falls back to Lua
})

vim.cmd.colorscheme("one")
