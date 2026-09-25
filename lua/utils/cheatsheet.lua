-- Floating cheat sheet: a few LazyVim defaults plus every custom keymap from lua/config/keymaps.lua
local M = {}

M.sections = { "Navigation", "Find", "LSP", "Editor", "Terminal" }

-- LazyVim defaults worth remembering (not set by this config)
M.defaults = {
  { lhs = "<S-h> / <S-l>", desc = "Prev / Next buffer", section = "Navigation" },
  { lhs = "<leader>bd", desc = "Close buffer", section = "Navigation" },
  { lhs = "gd / gr", desc = "Go to definition / references", section = "Navigation" },
  { lhs = "gI / gy", desc = "Go to implementation / type definition", section = "Navigation" },
  { lhs = "<C-o> / <C-i>", desc = "Jump back / forward", section = "Navigation" },
  { lhs = "<leader>e", desc = "File explorer", section = "Find" },
  { lhs = "<leader>ff", desc = "Find files", section = "Find" },
  { lhs = "<leader>/", desc = "Live grep", section = "Find" },
  { lhs = "<leader>ss", desc = "LSP workspace symbols", section = "LSP" },
  { lhs = "K", desc = "Hover docs", section = "LSP" },
  { lhs = "<leader>cf", desc = "Format file", section = "LSP" },
  { lhs = "<C-/>", desc = "Hide terminal (inside a terminal)", section = "Terminal" },
}

---@param keys {[1]:string, [2]:string, desc:string, section:string}[]
function M.open(keys)
  local by_section = {}
  local function add(section, lhs, desc)
    by_section[section] = by_section[section] or {}
    table.insert(by_section[section], ("  %-16s %s"):format(lhs, desc))
  end
  for _, k in ipairs(M.defaults) do
    add(k.section, k.lhs, k.desc)
  end
  for _, k in ipairs(keys) do
    add(k.section, k[2], k.desc)
  end

  local lines = {}
  for _, section in ipairs(M.sections) do
    if by_section[section] then
      lines[#lines + 1] = "── " .. section:upper() .. " "
      vim.list_extend(lines, by_section[section])
      lines[#lines + 1] = ""
    end
  end
  table.remove(lines)

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = width + 2

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"

  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Shortcuts ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = false

  for _, key in ipairs({ "q", "<Esc>", "<leader>?" }) do
    vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, silent = true })
  end
  return buf
end

return M
