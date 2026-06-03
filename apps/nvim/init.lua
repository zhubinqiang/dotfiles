-- ==========================================================================
-- 1. GLOBAL SETTINGS
-- ==========================================================================
vim.g.mapleader = ","

-- Pre-check: Is this a Development Machine?
local is_dev = vim.fn.filereadable(vim.fn.expand("~/.vim_dev_mode")) == 1

-- ==========================================================================
-- 2. BASIC OPTIONS
-- ==========================================================================
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true

-- ==========================================================================
-- 3. BOOTSTRAP LAZY.NVIM
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 4. PLUGIN LIST & CONFIGURATION
-- ==========================================================================
require("lazy").setup({
  -- UI: Color Scheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- UI: File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
    end,
  },

  -- UI: Status Line (Lualine)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = { theme = 'gruvbox' }
      })
    end
  },

  -- TOOL: Fuzzy Finder (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      -- Shortcut: Comma + ff to find files
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      -- Shortcut: Comma + fg to search text across files
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      -- Shortcut: Comma + fz (fuzzy) to find inside current file
      vim.keymap.set('n', '<leader>fz', builtin.current_buffer_fuzzy_find, {})
    end
  },

  -- TOOL: Quick Commenting
  -- Use 'gcc' to comment a line or 'gc' in visual mode
  {
      "tpope/vim-commentary",
      config = function()
          -- 关闭注释自动延续
          vim.api.nvim_create_autocmd("FileType", {
              pattern = { "sh", "bash", "zsh", "python", "lua", "*" },
              callback = function()
                  vim.opt_local.formatoptions:remove("r")
                  vim.opt_local.formatoptions:remove("o")
              end,
          })
      end,
  },


  -- TOOL: Auto Pairs (Pure Lua)
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        map_cr = false,
      })
    end
  },

  -- UI: Indent Guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- [PLUGIN: COC.NVIM]
  {
    'neoclide/coc.nvim',
    branch = 'release',
    -- Only enable coc if .vim_dev_mode exists
    enabled = is_dev, 
    config = function()
      -- This code runs ONLY when coc is loaded
      
      -- Dynamic Node Path
      if vim.fn.executable('node') == 1 then
        vim.g.coc_node_path = vim.fn.exepath('node')
      end

      -- Auto-install extensions
      vim.g.coc_global_extensions = {
        'coc-pyright',
        'coc-sh',
        'coc-json',
        'coc-clangd',
        'coc-git'
      }

      -- Define the CheckBackSpace function (Lua version)
      -- We attach it to _G (global) so the Vim-expression can see it
      _G.CheckBackSpace = function()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      -- Set keymaps for Dev Mode (gd, K, etc.)
      local keyset = vim.keymap.set
      local opts = {silent = true, noremap = true, expr = true}

      -- Tab completion logic
      -- Note: We use v:lua.CheckBackSpace() to call the Lua function above
      -- Tab: Next item or Indent
      keyset("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : v:lua.CheckBackSpace() ? "\<TAB>" : coc#refresh()]], opts)
      keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

      -- [FIXED] Use standard escape sequences for better responsiveness
      keyset("i", "<C-n>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"]], opts)
      keyset("i", "<C-p>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"]], opts)


      -- Enter: Confirm selection
      keyset("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)



      keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
      keyset("n", "K", ":call CocActionAsync('doHover')<CR>", {silent = true})
    end
  },

})

-- ==========================================================================
-- 5. PERSONAL KEYMAPS
-- ==========================================================================
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<leader>v', ':edit $MYVIMRC<CR>')




