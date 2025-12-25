require("nvchad.configs.lspconfig").defaults()
-- LSP с новым API
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Функция для поиска Python интерпретатора
local function get_python_path()
  local cwd = vim.fn.getcwd()
  -- Проверяем .venv в текущей директории
  local venv_python = cwd .. "/.venv/bin/python"
  if vim.fn.executable(venv_python) == 1 then
    return venv_python
  end
  -- Проверяем venv в текущей директории
  venv_python = cwd .. "/venv/bin/python"
  if vim.fn.executable(venv_python) == 1 then
    return venv_python
  end
  -- Проверяем poetry
  local poetry_venv = vim.fn.trim(vim.fn.system "poetry env info --path 2>/dev/null")
  if poetry_venv ~= "" then
    return poetry_venv .. "/bin/python"
  end
  -- Fallback на системный python
  return "python3"
end

-- Настройка серверов с новым API
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
})

vim.lsp.config("basedpyright", {
  capabilities = capabilities,
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path()
  end,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
      },
    },
    python = {},
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

-- Включаем LSP серверы
vim.lsp.enable({
  "ts_ls",
  "basedpyright",
  "ruff",
  "jsonls",
  "cssls",
  "html",
  "yamlls",
  "dockerls",
  "gopls",
  "lua_ls",
  "eslint",
})

-- read :h vim.lsp.config for changing options of lsp servers
