return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    -- Normal mode
    {
      "<leader>tt",
      "<cmd>ToggleTerm direction=float<cr>",
      desc = "Toggle Floating Terminal",
      mode = "n",
    },
    -- Terminal mode
    {
      "<leader>tt",
      [[<C-\><C-n><cmd>ToggleTerm direction=float<cr>]],
      desc = "Toggle Floating Terminal",
      mode = "t",
    },
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
