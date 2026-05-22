return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>tt",
      function()
        Snacks.terminal(nil, { win = { position = "float", border = "rounded" } })
      end,
      desc = "Toggle Floating Terminal",
      mode = { "n", "t" },
    },
    {
      "<leader>tb",
      function()
        Snacks.terminal(nil, { win = { position = "bottom" } })
      end,
      desc = "Toggle Bottom Terminal",
      mode = { "n", "t" },
    },
  },
}
