require("nvchad.configs.lspconfig").defaults()
-- LSP с новым API
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local venv = vim.fn.trim(vim.fn.system "poetry env info --path")

-- Настройка серверов с новым API
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      pythonPath = venv .. "/bin/python",
      analysis = {
        autoSearchPaths = true,
        typeCheckingMode = "basic",
      },
    },
  },
})

vim.lsp.config("jsonls", {
  capabilities = capabilities,
})

vim.lsp.config("cssls", {
  capabilities = capabilities,
})

vim.lsp.config("html", {
  capabilities = capabilities,
})

vim.lsp.config("yamlls", {
  capabilities = capabilities,
})

vim.lsp.config("dockerls", {
  capabilities = capabilities,
})

vim.lsp.config("ruff", {
  capabilities = capabilities,
})

vim.lsp.config("gopls", {
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("eslint", {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { async = false }
      end,
    })
  end,
})

-- Иконки для автодополнения LSP
local protocol = require "vim.lsp.protocol"
protocol.CompletionItemKind = {
  "", -- Text
  "", -- Method
  "", -- Function
  "", -- Constructor
  "", -- Field
  "", -- Variable
  "", -- Class
  "ﰮ", -- Interface
  "", -- Module
  "", -- Property
  "", -- Unit
  "", -- Value
  "", -- Enum
  "", -- Keyword
  "﬌", -- Snippet
  "", -- Color
  "", -- File
  "", -- Reference
  "", -- Folder
  "", -- EnumMember
  "", -- Constant
  "", -- Struct
  "", -- Event
  "ﬦ", -- Operator
  "", -- TypeParameter
}

-- read :h vim.lsp.config for changing options of lsp servers
