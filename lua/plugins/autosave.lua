return {
  "Pocco81/auto-save.nvim",
  event = "InsertLeave",
  opts = {
    enabled = true,
    execution_message = {
      enabled = false,
    },
    trigger_events = {
      "InsertLeave",
      "TextChanged",
    },
    debounce_delay = 135,
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")

      return fn.getbufvar(buf, "&modifiable") == 1
        and utils.not_in(fn.getbufvar(buf, "&filetype"), { "alpha", "dashboard" })
    end,
  },
}
