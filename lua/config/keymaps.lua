-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Every custom keymap lives in this table; `section` groups it in the <leader>? cheat sheet (utils/cheatsheet.lua).
-- LSP-only keymaps go in plugins/lsp.lua instead (LazyVim sets those per buffer, which would shadow a global map).

local keys = {
  -- Find
  {
    "n",
    "<leader>fs",
    function()
      require("utils.symbols").pick()
    end,
    desc = "Find functions/classes (project)",
    section = "Find",
  },
  {
    "n",
    "<leader>fS",
    function()
      require("utils.symbols").pick({
        title = "Classes",
        kinds = { "Class", "Struct", "Interface", "Enum", "TypeParameter" },
      })
    end,
    desc = "Find classes/types (project)",
    section = "Find",
  },
  {
    "n",
    "<leader>fi",
    function()
      Snacks.picker.files({ cwd = vim.fn.getcwd() .. "/src", hidden = true, ignored = true })
    end,
    desc = "Find files in ignored src/",
    section = "Find",
  },

  -- LSP (peek = Snacks pickers)
  {
    "n",
    "<leader>pd",
    function()
      Snacks.picker.lsp_definitions()
    end,
    desc = "Peek definition",
    section = "LSP",
  },
  {
    "n",
    "<leader>pi",
    function()
      Snacks.picker.lsp_implementations()
    end,
    desc = "Peek implementation",
    section = "LSP",
  },
  {
    "n",
    "<leader>pt",
    function()
      Snacks.picker.lsp_type_definitions()
    end,
    desc = "Peek type definition",
    section = "LSP",
  },

  -- Editor
  { "i", "jj", "<Esc>", desc = "Exit insert mode", section = "Editor" },
  { "n", "<leader>ya", "<cmd>%y+<CR>", desc = "Yank entire file", section = "Editor" },
  {
    "n",
    "<leader>yi",
    function()
      require("utils.import").yank_import()
    end,
    desc = "Yank import for symbol (py/js/rs)",
    section = "Editor",
  },
  {
    "n",
    "<leader>td",
    function()
      require("utils.testpath").copy()
    end,
    desc = "Copy Python dotted test path",
    section = "Editor",
  },

  -- Terminal (normal mode only: a <leader> map in terminal mode delays every typed space)
  {
    "n",
    "<leader>tt",
    function()
      Snacks.terminal(nil, { win = { position = "float", border = "rounded" } })
    end,
    desc = "Toggle floating terminal",
    section = "Terminal",
  },
  {
    "n",
    "<leader>tb",
    function()
      Snacks.terminal(nil, { win = { position = "bottom" } })
    end,
    desc = "Toggle bottom terminal",
    section = "Terminal",
  },
}

table.insert(keys, {
  "n",
  "<leader>?",
  function()
    require("utils.cheatsheet").open(keys)
  end,
  desc = "Cheat sheet",
  section = "Editor",
})

for _, k in ipairs(keys) do
  vim.keymap.set(k[1], k[2], k[3], { desc = k.desc, silent = true })
end

return keys -- read by scripts/check_session.lua (LazyVim loads this file with require)
