-- Distinct glyphs per git state so changes are readable without color
local signs = {
  add = { text = "+" },
  change = { text = "~" },
  delete = { text = "_" },
  topdelete = { text = "‾" },
  changedelete = { text = "≃" },
  untracked = { text = "┆" },
}

return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = signs,
    signs_staged = signs,
  },
}
