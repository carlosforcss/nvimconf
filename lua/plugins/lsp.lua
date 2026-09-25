-- LSP keymaps must be registered here: LazyVim sets these per buffer on attach, so a global map would be shadowed
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].keys = opts.servers["*"].keys or {}
    table.insert(opts.servers["*"].keys, {
      "<leader>ss",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "Search symbols (workspace / LSP)",
    })
  end,
}
