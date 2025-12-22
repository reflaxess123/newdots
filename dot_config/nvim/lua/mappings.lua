require "nvchad.mappings"

local map = vim.keymap.set

map("i", "jk", "<ESC>")
vim.keymap.set("n", "<leader>pq", ":bd!<CR>", { desc = "Force close buffer", noremap = true, silent = true })

-- Move between windows with Ctrl + arrow keys
map("n", "<C-Up>", "<C-w>k", { desc = "Move to window above", silent = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Move to window below", silent = true })
map("n", "<C-Left>", "<C-w>h", { desc = "Move to window left", silent = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Move to window right", silent = true })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle nvim tree", silent = true })

-- Диагностика LSP
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic message", silent = true })

-- Переключение inline диагностики
local function toggle_virtual_text()
  local config = vim.diagnostic.config()
  vim.diagnostic.config {
    virtual_text = not config.virtual_text,
  }
  print("Virtual text: " .. (config.virtual_text and "disabled" or "enabled"))
end

map("n", "<leader>dt", toggle_virtual_text, { desc = "Toggle inline diagnostic text", silent = true })

-- Claude Code toggle
map({ "n", "i", "v", "t" }, "<C-;>", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude", silent = true, noremap = true })

-- Code runner
map("n", "<leader>rr", ":RunCode<CR>", { desc = "Run code", silent = true })
