-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "doomchad",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    -- Волнистое подчеркивание для диагностики
    DiagnosticUnderlineError = { undercurl = true, sp = "red" },
    DiagnosticUnderlineWarn = { undercurl = true, sp = "orange" },
    DiagnosticUnderlineInfo = { undercurl = true, sp = "blue" },
    DiagnosticUnderlineHint = { undercurl = true, sp = "green" },
  },
}

M.ui = {
  statusline = {
    separator_style = "round",
  },
}

-- M.nvdash = {
--   load_on_startup = true
-- }

M.plugins = {
  ["folke/noice.nvim"] = {
    enabled = false,
  },
}

-- Настройка диагностики LSP
vim.diagnostic.config {
  virtual_text = false, -- Отключаем inline ошибки
  underline = true, -- Включаем подчеркивание
  signs = true,
  update_in_insert = false,
  severity_sort = true,
}

-- Принудительно устанавливаем волнистое подчеркивание
vim.cmd [[
  hi DiagnosticUnderlineError gui=undercurl guisp=red cterm=undercurl
  hi DiagnosticUnderlineWarn gui=undercurl guisp=yellow cterm=undercurl  
  hi DiagnosticUnderlineInfo gui=undercurl guisp=blue cterm=undercurl
  hi DiagnosticUnderlineHint gui=undercurl guisp=green cterm=undercurl
]]

return M
