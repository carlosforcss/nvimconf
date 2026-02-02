return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "BufReadPost",
  build = ":Copilot auth",
  opts = {
    panel = {
      enabled = false,
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<C-l>", -- accept full suggestion
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
  },
  config = function(_, opts)
    require("copilot").setup(opts)

    -- Force accept mapping even if copilot.lua doesn't create it
    vim.keymap.set("i", "<C-l>", function()
      require("copilot.suggestion").accept()
    end, { silent = true, desc = "Copilot Accept" })
  end,
}
