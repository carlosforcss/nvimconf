return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "BufReadPost",
  build = ":Copilot auth",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
    },
    panel = { enabled = false },
  },
}
