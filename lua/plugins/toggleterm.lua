return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>i",            desc = "Toggle Floating Terminal",        mode = "n" },
    { "<leader>tb", "<cmd>ToggleTerm direction=horizontal<cr>i",       desc = "Toggle Bottom Terminal",          mode = "n" },
    { "<leader>tt", [[<C-\><C-n><cmd>ToggleTerm direction=float<cr>]], desc = "Toggle Floating Terminal",        mode = "t" },
    { "<leader>tb", [[<C-\><C-n><cmd>ToggleTerm direction=horizontal<cr>]], desc = "Toggle Bottom Terminal",    mode = "t" },
  },
  opts = {
    direction = "float",
    open_mapping = false,
    start_in_insert = true,
    float_opts = {
      border = "rounded",
    },
  },
}
