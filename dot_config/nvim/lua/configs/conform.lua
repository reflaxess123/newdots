local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    python = { "ruff_format" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    css = { "prettierd" },
  },
  formatters = {
    prettierd = {
      prepend_args = { "--tab-width", "2" },
    },
    stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    },
  },

  format_on_save = function(bufnr)
    -- Проверяем, есть ли синтаксические ошибки
    local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
    if #diagnostics > 0 then
      -- Если есть ошибки, показываем уведомление и не форматируем
      vim.notify(
        "Форматирование пропущено из-за синтаксических ошибок",
        vim.log.levels.WARN
      )
      return false
    end

    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
}

return options
