return {
  {
    "stevearc/conform.nvim",
    lazy = false,
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mfussenegger/nvim-lint",
    lazy = false,
    config = function()
      require "configs.lint"
    end,
  },
  {

    "folke/which-key.nvim",
    lazy = false,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
  },
  {
    "gelguy/wilder.nvim",
    lazy = false,
    config = function()
      local wilder = require "wilder"
      wilder.setup {
        modes = { ":", "/", "?" },
      }
      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer(wilder.popupmenu_palette_theme {
          border = "rounded",
          highlights = {
            default = wilder.make_hl("Pmenu", "Normal"),
            selection = wilder.make_hl("PmenuSel", "PmenuSel"),
          },
        })
      )
    end,
  },
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.25, -- насколько затемнять (от 0 до 1)
        color = { "Normal", "#ffffff" },
        inactive = false,
      },
      context = 15, -- сколько строк вокруг текущего блока оставить яркими
    },
    keys = {
      { "<leader>tw", "<cmd>Twilight<CR>", desc = "Toggle Twilight" },
    },
  },
  {
    "CRAG666/code_runner.nvim",
    lazy = false,
    config = function()
      require("code_runner").setup {
        mode = "term",
        focus = false,
        startinsert = false,
        filetype = {
          javascript = 'cd $dir && node "$fileName"',
          typescript = 'cd $dir && npx ts-node "$fileName"',
          python = 'cd $dir && python "$fileName"',
          lua = 'cd $dir && lua "$fileName"',
        },
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.nvim", -- или 'echasnovski/mini.icons'
      -- 'nvim-tree/nvim-web-devicons', -- если нужен
    },
    ft = { "markdown", "quarto" }, -- <--- вот это ОЧЕНЬ важно!
    opts = {
      anti_conceal = { enabled = false },
    },
  },
}
