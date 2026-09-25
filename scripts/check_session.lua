-- Loaded inside a real (pty) nvim session by scripts/check.sh. Writes OK/FAIL/SKIP lines to $CHECK_OUT, then quits.
local results = {}
local function check(ok, label, detail)
  results[#results + 1] = (ok and "OK   " or "FAIL ") .. label .. ((not ok and detail) and (": " .. detail) or "")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    vim.defer_fn(function()
      -- Colorscheme: plain "catppuccin" would load Neovim's built-in static port
      check(vim.g.colors_name == "catppuccin-mocha", "colorscheme", tostring(vim.g.colors_name))

      -- Every entry of the keymap table is mapped with its desc
      local keys = package.loaded["config.keymaps"]
      check(type(keys) == "table", "keymap table", "config.keymaps did not return its table")
      local missing = {}
      for _, k in ipairs(type(keys) == "table" and keys or {}) do
        local m = vim.fn.maparg(k[2], k[1], false, true)
        if m.desc ~= k.desc then
          missing[#missing + 1] = k[1] .. " " .. k[2]
        end
      end
      check(#missing == 0, "keymaps (" .. #(keys or {}) .. ")", table.concat(missing, ", "))

      -- <leader>ss must be workspace symbols even after LazyVim's LSP keymaps attach
      local attached = vim.wait(20000, function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end, 200)
      if attached then
        vim.wait(1000)
        local ss = vim.fn.maparg("<leader>ss", "n", false, true)
        check(ss.desc == "Search symbols (workspace / LSP)", "<leader>ss in LSP buffer", tostring(ss.desc))
      else
        results[#results + 1] = "SKIP <leader>ss (no LSP attached within 20s)"
      end

      -- No startup errors (E1568 comes from the pty itself not answering a terminal query)
      local errors = {}
      for _, line in ipairs(vim.split(vim.fn.execute("messages"), "\n")) do
        if (line:match("E%d+:") or line:match("[Ee]rror")) and not line:match("E1568") then
          errors[#errors + 1] = line
        end
      end
      check(#errors == 0, "startup messages", table.concat(errors, " | "))

      vim.fn.writefile(results, vim.env.CHECK_OUT)
      vim.cmd("qa!")
    end, 500)
  end,
})
