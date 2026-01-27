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

-- Custom functions
-- Copies: package.tests.test_file.TestClass.test_func
-- (project-root-relative module path + nearest class/function)
local function copy_python_dotted_test()
  -- project root (LazyVim) fallback to cwd
  local ok_util, util = pcall(require, "lazyvim.util")
  local root = (ok_util and util.root.get()) or vim.loop.cwd()

  -- file -> module dotted path
  local abs = vim.fn.expand("%:p")
  local rel = vim.fs.relpath(root, abs) or vim.fn.expand("%")
  rel = rel:gsub("\\", "/") -- windows

  local mod = rel:gsub("%.py$", ""):gsub("/", ".")
  mod = mod:gsub("%.__init__$", "") -- package/__init__.py => package

  -- nearest class + function via Treesitter
  local ts_ok, ts = pcall(require, "vim.treesitter")
  local class_name, func_name

  if ts_ok then
    local node = ts.get_node()
    while node do
      local t = node:type()
      if not func_name and t == "function_definition" then
        local name = node:field("name")[1]
        func_name = name and vim.treesitter.get_node_text(name, 0) or nil
      end
      if not class_name and t == "class_definition" then
        local name = node:field("name")[1]
        class_name = name and vim.treesitter.get_node_text(name, 0) or nil
      end
      node = node:parent()
    end
  end

  local dotted = mod
  if class_name then
    dotted = dotted .. "." .. class_name
  end
  if func_name then
    dotted = dotted .. "." .. func_name
  end

  vim.fn.setreg("+", dotted)
  vim.notify("Copied: " .. dotted)
end

vim.keymap.set("n", "<leader>td", copy_python_dotted_test, { desc = "Copy dotted test path" })

vim.keymap.set("n", "<leader>fi", function()
  require("snacks").picker.files({
    cwd = vim.fn.getcwd() .. "/src",
    hidden = true,
    ignored = true,
  })
end, { desc = "Find files in ignored src folder" })

vim.keymap.set("n", "<leader>ya", function()
  vim.cmd("normal! ggVG")
  vim.cmd('normal! "+y')
end, { desc = "Copy entire file to clipboard" })

-- Remove Neovim native snippet Tab behavior
vim.keymap.del("i", "<Tab>")
vim.keymap.del("s", "<Tab>")
vim.keymap.del("i", "<S-Tab>")
vim.keymap.del("s", "<S-Tab>")
