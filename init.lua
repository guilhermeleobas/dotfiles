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

-- Telescope: only Ctrl+P (find files). Other pickers still available via :Telescope
map("n", "<C-p>", function() require("telescope.builtin").find_files() end, { desc = "Find files (Ctrl+P)" })

-- vim-easy-align (visual mode)
map("x", "ga", "<Plug>(EasyAlign)", { desc = "EasyAlign" })

--------------------------------------------------------------------------------
-- Plugins (vim.pack — native manager, Neovim 0.12+)
--------------------------------------------------------------------------------
-- Build hooks: run compiled steps after a plugin is installed/updated.
-- Register BEFORE vim.pack.add so first install triggers it.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      -- :wait() makes it synchronous so the native sorter is ready immediately
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    end
  end,
})

local gh = function(repo) return "https://github.com/" .. repo end

-- Installs on first run (blocking), then loads all listed plugins.
vim.pack.add({
  -- File tree (neo-tree + its deps)
  { src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") },
  { src = gh("MunifTanjim/nui.nvim") },
  { src = gh("nvim-tree/nvim-web-devicons") }, -- icons (needs a Nerd Font)

  -- Fuzzy finder framework (plenary is a required dep)
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("nvim-telescope/telescope.nvim") },
  { src = gh("nvim-telescope/telescope-fzf-native.nvim") }, -- native C sorter

  -- Statusline
  { src = gh("vim-airline/vim-airline") },
  { src = gh("vim-airline/vim-airline-themes") },

  -- Git diff/history viewer (uses plenary above)
  { src = gh("sindrets/diffview.nvim") },

  -- Git gutter signs + per-line blame
  { src = gh("lewis6991/gitsigns.nvim") },

  -- Editing helpers
  { src = gh("jiangmiao/auto-pairs") },      -- auto close brackets
  { src = gh("Yggdroot/indentLine") },       -- indent guides
  { src = gh("junegunn/vim-easy-align") },
  { src = gh("rhysd/accelerated-jk") },      -- faster j/k

  -- Syntax/structure: treesitter (+ semantic text objects)
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "master" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects") },

  -- LSP: configs + auto-installer for language servers
  { src = gh("neovim/nvim-lspconfig") },
  { src = gh("mason-org/mason.nvim") },
  { src = gh("mason-org/mason-lspconfig.nvim") },

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
local t = require("telescope")
t.setup({})
pcall(t.load_extension, "fzf") -- enable native sorter if built

-- Git signs + per-line blame
require("gitsigns").setup({
  current_line_blame = true, -- inline blame at end of cursor line
  current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local o = function(desc) return { buffer = bufnr, desc = desc } end
    map("n", "]c", function() gs.nav_hunk("next") end, o("Next hunk"))
    map("n", "[c", function() gs.nav_hunk("prev") end, o("Prev hunk"))
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, o("Blame line (full)"))
    map("n", "<leader>ht", gs.toggle_current_line_blame, o("Toggle inline blame"))
    map("n", "<leader>hp", gs.preview_hunk, o("Preview hunk"))
    map("n", "<leader>hd", gs.diffthis, o("Diff this"))
  end,
})

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

-- Completion (blink.cmp). LSP source is on by default.
require("blink.cmp").setup({
  keymap = { preset = "default" }, -- <C-space> open, <C-n>/<C-p> select, <CR> accept
  fuzzy = { implementation = "prefer_rust_with_warning" }, -- falls back to Lua
})

-- LSP: install servers via mason, then enable them (native vim.lsp).
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "clangd", "bashls" },
  automatic_enable = true, -- calls vim.lsp.enable() for installed servers
})

-- Advertise blink's completion capabilities to every server.
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

-- Show diagnostics inline.
vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- Buffer-local LSP keymaps (in addition to Neovim 0.11 defaults:
-- K hover, grn rename, gra code action, grr references, gri implementation).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local o = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
    vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, o)
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, o)
  end,
})

vim.cmd.colorscheme("one")
