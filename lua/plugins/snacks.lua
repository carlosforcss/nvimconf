return {
  "folke/snacks.nvim",
  opts = {
    scroll = { animate = { duration = { step = 10, total = 100 } } },
    indent = { animate = { enabled = false } },
    terminal = {
      win = {
        -- Buffer-local to terminal windows, so it wins over LazyVim's global terminal-mode <C-/>
        keys = {
          hide_slash = { "<C-/>", "hide", mode = "t", desc = "Hide Terminal" },
          hide_underscore = { "<C-_>", "hide", mode = "t", desc = "Hide Terminal" },
        },
      },
    },
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              width = 32,
              min_width = 32,
            },
          },
        },
      },
    },
  },
}
