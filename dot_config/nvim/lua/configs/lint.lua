local lint = require "lint"

lint.linters_by_ft = {
  go = { "golangci_lint" },
}

-- Запускаем линтер автоматически при сохранении
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})
