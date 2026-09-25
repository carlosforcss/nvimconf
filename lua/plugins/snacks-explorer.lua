return {
  "folke/snacks.nvim",
  opts = {
    scroll = { animate = { duration = { step = 10, total = 100 } } },
    indent = { animate = { enabled = false } },
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
