-- ==========================================================================
-- 1. GLOBAL SETTINGS & ENVIRONMENT
-- ==========================================================================
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Pre-check: Is this a Development Machine? (Controls heavy plugins like CoC)
local is_dev = vim.fn.filereadable(vim.fn.expand("~/.vim_dev_mode")) == 1

-- ==========================================================================
-- 2. CORE OPTIONS (vim.opt)
-- ==========================================================================
local opt = vim.opt

-- Display & UI
opt.number = true
opt.termguicolors = true
opt.showcmd = true
opt.ruler = true
opt.cursorline = true

-- Indentation & Tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "yaml", "json", "markdown" },
  callback = function()
    -- opt_local 确保这个 2 个空格的设定只在当前的 Lua 文件内生效
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Files & Backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.fileencodings = "utf-8,gbk,gb2312,gb18020"

-- Mouse & Clipboard
opt.mouse = "a"

-- System clipboard via OSC 52 (Excellent for seamless cross-terminal copies)
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Sync yanked text to system clipboard via OSC 52',
  callback = function()
    if vim.v.event.operator == 'y' then
      require('vim.ui.clipboard.osc52').copy('+')(vim.v.event.regcontents)
    end
  end,
})

-- Prevent comment continuation on new lines (Your excellent autocmd)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh", "python", "lua", "*" },
  callback = function()
    vim.opt_local.formatoptions:remove("r")
    vim.opt_local.formatoptions:remove("o")
  end,
})

-- ==========================================================================
-- 3. CORE KEYMAPS
-- ==========================================================================
local map = vim.keymap.set

-- Basic Operations
map('n', '<leader>w', ':w<CR>', { desc = "Save file" })
map('n', '<leader>q', ':q<CR>', { desc = "Quit" })
-- Configuration (Vimrc) micro-drawer
map('n', '<leader>ve', ':edit $MYVIMRC<CR>', { desc = "Edit configuration (current window)" })
map('n', '<leader>vv', ':vsplit $MYVIMRC<CR>', { desc = "Edit configuration (vertical split)" })
map('n', '<leader>vs', ':source $MYVIMRC<CR>', { desc = "Source/Reload configuration" })
map('n', '<leader>wf', ':w !sudo tee %<CR>', { desc = "Force save with sudo" })

-- 保持 Neovim 剪贴板独立，通过快捷键与系统剪贴板交互
map({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({"n", "v"}, "<leader>d", '"+d', { desc = "Delete to system clipboard" })

-- Search & Navigation
map('n', '<F4>', ':nohlsearch<CR>', { desc = "Clear search highlight" })
-- 按 Esc 键时，清除搜索高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
-- 让 * 键在 Visual (选中) 模式下也能搜索当前选中的文本
map("v", "*", [[y/\V<C-R>=escape(@", '/\')<CR><CR>]], { desc = "Search visually selected text" })
map('n', 'H', 'gT', { desc = "Previous tab" })
map('n', 'L', 'gt', { desc = "Next tab" })
map('n', '<leader>tn', ':tabnew<CR>', { desc = "New tab" })
map('n', '<leader>0', ':tablast<CR>', { desc = "Last tab" })

-- 在可视模式下，直接按上下键移动选中的代码块
map("v", "<down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- ==========================================================================
-- 4. BOOTSTRAP LAZY.NVIM
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
-- 5. PLUGIN LIST & CONFIGURATION
-- ==========================================================================
require("lazy").setup({
  -- -- UI: Color Scheme
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd("colorscheme gruvbox")
  --   end,
  -- },

  -- UI: Color Scheme (OneDark)
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- 确保主题在所有插件加载前最先加载
    config = function()
      -- 可选：你可以在这里选不同风格的 onedark，比如 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
      require('onedark').setup({
          style = 'dark'
      })
      -- 执行切换主题的命令
      vim.cmd("colorscheme onedark")
    end,
  },

  -- UI: Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = { theme = 'gruvbox' }
      })
    end
  },

  -- UI: File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle Explorer" },
      { "<F7>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle Explorer (Legacy)" },
    },
    config = function()
      require("nvim-tree").setup({
        filters = { dotfiles = false, custom = { "^.git$", "^__pycache__$" } },
      })
    end,
  },

  -- UI: 快捷键提示面板 (终极作弊条)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- 默认配置已经足够完美，它会自动读取你配置中的 desc 描述
    },
  },

  -- UI: 高亮并一键清理多余空格
  {
    "echasnovski/mini.trailspace",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mini.trailspace").setup({
        -- 这里可以直接留空，默认配置已经极其完美
      })

      -- 顺手绑一个快捷键，比如按 <leader>cw (Clear Whitespace) 一键清理
      vim.keymap.set("n", "<leader>cw", function()
        require("mini.trailspace").trim()
      end, { desc = "Clear Trailing Whitespace" })
    end,
  },

  -- TOOL: 现代化的代码对齐工具 (完美替代 vim-easy-align)
  {
    "echasnovski/mini.align",
    version = "*",
    keys = {
      { "ga", mode = { "n", "v" }, desc = "Align text" },
      { "gA", mode = { "n", "v" }, desc = "Align text with preview" },
    },
    config = function()
      require("mini.align").setup()
    end,
  },

  {
    "honza/vim-snippets",
    -- lazy = true, -- coc-snippets
  },

  {
    "rafamadriz/friendly-snippets",
  },

  -- TOOL: Fuzzy Finder (Telescope)
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
      -- 这一步必须放在 config 函数里面，等插件加载完了再 require
      local actions = require("telescope.actions")

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-s>"] = actions.select_horizontal, -- Ctrl+s 水平分屏
              ["<C-a>"] = actions.select_vertical,   -- Ctrl+a 垂直分屏
            }
          }
        }
      })
    end,

    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
      { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Fuzzy Find in File" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Find Keymaps" },
    },
  },

  -- TOOL: Git Integration (Fugitive)
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gd", ":Git diff<CR>", desc = "Git diff" },
      { "<leader>gds", ":Gvdiffsplit<CR>", desc = "Git diff split" },
      { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
      { "<leader>gl", ":Git log<CR>", desc = "Git log" },
    },
  },

  -- -- Git: 左侧实时变动提示与内联 Blame
  -- {
  --   "lewis6991/gitsigns.nvim",
  --   event = { "BufReadPre", "BufNewFile" },
  --   opts = {
  --     -- 开启极其好用的当前行自动 Blame
  --     current_line_blame = true,
  --     current_line_blame_opts = {
  --       delay = 500, -- 鼠标停留 0.5 秒后显示 blame 信息
  --     },
  --   },
  --   keys = {
  --     -- 快捷键：预览当前代码块的 Diff
  --     { "<leader>gd", "<cmd>Gitsigns preview_hunk<CR>", desc = "Git Diff (Preview Hunk)" },
  --     -- 快捷键：如果你想看更详细的整文件 Blame 分屏
  --     { "<leader>gb", "<cmd>Gitsigns blame_line<CR>", desc = "Git Blame Line" },
  --   }
  -- },

  -- -- TOOL: Quick Commenting (Modern Lua Alternative)
  -- -- Note: Swapped 'vim-commentary' for 'Comment.nvim' as it integrates better with Lua and Treesitter
  -- -- Don't need this plugin since neovim >= 0.10
  -- {
  --   "numToStr/Comment.nvim",
  --   config = function()
  --     require("Comment").setup()
  --   end,
  -- },

  -- TOOL: Auto Pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({ map_cr = false })
    end
  },

  -- UI: Indent Guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- [PLUGIN: COC.NVIM] (The Engine)
  {
    'neoclide/coc.nvim',
    branch = 'release',
    enabled = is_dev,
    config = function()
      if vim.fn.executable('node') == 1 then
        vim.g.coc_node_path = vim.fn.exepath('node')
      end

      -- Restored your missing snippets extension
        -- 'coc-pyright', 'coc-sh', 'coc-json', 'coc-clangd', 'coc-git', 'coc-snippets'
      vim.g.coc_global_extensions = {
        'coc-clangd', 'coc-diagnostic', 'coc-explorer', 'coc-git',
        'coc-html', 'coc-json', 'coc-lists', 'coc-lua', 'coc-snippets',
        'coc-pyright', 'coc-sh'
      }

      ---@diagnostic disable-next-line: duplicate-set-field
      _G.CheckBackSpace = function()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      local keyset = vim.keymap.set
      local opts = {silent = true, noremap = true, expr = true}

      -- Tab completion logic
      keyset("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : v:lua.CheckBackSpace() ? "\<TAB>" : coc#refresh()]], opts)
      keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
      keyset("i", "<C-n>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"]], opts)
      keyset("i", "<C-p>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"]], opts)
      keyset("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

      -- Code Navigation & Actions
      keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
      keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
      keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
      keyset("n", "gr", "<Plug>(coc-references)", {silent = true})
      keyset("n", "K", ":call CocActionAsync('doHover')<CR>", {silent = true})

      keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})

      -- Formatting
      keyset("x", "<leader>fm", "<Plug>(coc-format-selected)", {silent = true})
      keyset("n", "<leader>fm", "<Plug>(coc-format-selected)", {silent = true})

      -- Snippets
      -- Snippets configuration (Snippet Edit)
      keyset("n", "<leader>se", ":CocCommand snippets.editSnippets<CR>", {silent = true, desc = "Edit Snippets"})
      keyset("i", "<C-l>", "<Plug>(coc-snippets-expand)", {silent = true})
      keyset("i", "<C-j>", "<Plug>(coc-snippets-expand-jump)", {silent = true})
      keyset("s", "<C-j>", "<Plug>(coc-snippets-expand-jump)", {silent = true})
      keyset("i", "<C-k>", "<Plug>(coc-snippets-jump-prev)", {silent = true})
      keyset("s", "<C-k>", "<Plug>(coc-snippets-jump-prev)", {silent = true})
    end
  },

  -- 代码大纲侧边栏 (完美融合 CoC)
  {
    "liuchengxu/vista.vim",
    enabled = is_dev,
    cmd = { "Vista", },
    keys = {
      -- 绑定快捷键 <leader>tb (TagBar) 来一键开关侧边栏
      { "<leader>tb", "<cmd>Vista!!<CR>", desc = "Toggle Tagbar (Vista)" },
    },
    init = function()
      -- 核心魔法：告诉 Vista 优先使用 coc.nvim 作为提取符号的引擎
      vim.g.vista_default_executive = "coc"

      -- 美化设置：让图标更好看一点 (可选)
      vim.g.vista_icon_indent = { "╰─▸ ", "├─▸ " }
      vim.g.vista_sidebar_width = 30
    end,
  },

  -- TOOL: 优雅解决无权限保存 (替代 sudo tee)
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" }, -- 懒加载：只有你敲命令时才加载插件
    keys = {
      -- 重新绑定你的强制保存快捷键，现在它调用的是插件的命令
      { "<leader>wf", "<cmd>SudaWrite<CR>", desc = "Force save with sudo" }
    }
  },

  -- AI 助手: 本地 Ollama 驱动
  {
    "David-Kunz/gen.nvim",
    enabled = is_dev,
    opts = {
        model = "llama3.2",     -- 指定我们要用的本地模型
        host = "localhost",     -- Ollama 的默认本地地址
        port = "11434",         -- Ollama 的默认端口
        -- display_mode = "split", -- AI 的回复会从右侧弹出一个分屏显示
        display_mode = "float", -- AI 的回复会显示浮动窗口
        show_prompt = true,     -- 显示你提问的提示词
        show_model = true,      -- 显示当前正在使用的模型名称
    },
    keys = {
      -- 绑定快捷键：普通模式和可视模式下按下 ,a 呼出 AI 菜单 (a 代表 AI)
      { "<leader>a", ":Gen<CR>", mode = { "n", "v" }, desc = "Ollama AI Assistant" }
    },

    config = function(_, opts)
      -- 1. 加载默认配置
      require("gen").setup(opts)

      -- 2. 注入你专属的中文指令
      require('gen').prompts['Chat_With_Code'] = {
        prompt = [[
请看下面的代码:
```$filetype
$text
我的问题是: $input]],
        replace = false
      }

      -- 2. 自定义：一键加中文注释 (直接替换选中的代码)
      require('gen').prompts['Add_Comments'] = {
          prompt = "请给下面的代码添加清晰、专业的中文注释。重点解释核心逻辑。只输出包含注释的代码，绝对不要输出任何其他的解释性文字：\n```$filetype\n$text\n```",
          replace = true  -- 🌟 关键：设为 true，生成后会自动覆盖你高亮选中的旧代码
      }

      -- 3. 自定义：一键排错与审查 (弹出对话框，指出问题)
      require('gen').prompts['Find_Bugs'] = {
          prompt = "请作为资深工程师审查以下代码。指出潜在的Bug、逻辑错误或可优化的性能瓶颈。用中文列出问题，并提供修改建议：\n```$filetype\n$text\n```",
          replace = false -- 🌟 关键：设为 false，只在浮动窗口给你解释，不乱动你的文件
      }
    end
  },

})

