-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- jj in insert mode goes to normal mode
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "gd", function()
  require("snacks").picker.lsp_definitions()
end, { desc = "Goto Definition (picker)" })

vim.keymap.set("n", "<leader>ss", function()
  Snacks.picker.lsp_workspace_symbols()
end, { desc = "Search symbols (workspace / LSP)" })

vim.keymap.set("n", "gd", function()
  require("snacks").picker.lsp_definitions()
end, { desc = "Goto Definition (picker)" })

vim.keymap.set("n", "gr", function()
  require("snacks").picker.lsp_references()
end, { desc = "Find References (usages)" })

-- Peek group
vim.keymap.set("n", "<leader>pd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek Definition" })
vim.keymap.set("n", "<leader>pi", "<cmd>Lspsaga peek_implementation<CR>", { desc = "Peek Implementation" })
vim.keymap.set("n", "<leader>pt", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek Type Definition" })
