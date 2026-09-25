return {
  "okuuva/auto-save.nvim",
  version = "*",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost", "QuitPre" },
      defer_save = { "InsertLeave" },
      cancel_deferred_save = { "InsertEnter" },
    },
    debounce_delay = 1000,
    condition = function(buf)
      local fn = vim.fn
      return fn.getbufvar(buf, "&modifiable") == 1
        and not vim.tbl_contains({ "alpha", "dashboard" }, fn.getbufvar(buf, "&filetype"))
    end,
  },
}
