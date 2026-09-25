-- Catppuccin Mocha tuned for achromatopsia: every syntax role gets its own lightness tier,
-- and roles that share a tier are separated by font style (bold / italic / underline shape).
local p = {
  base = "#0f0f15", -- L* 5
  mantle = "#0a0a0f",
  crust = "#060609",
  cursorline = "#1c1e2a", -- L* 12
  selection = "#3a3f58", -- L* 27
  keyword = "#f5eaff", -- L* 94  bold
  type = "#f5dfa0", -- L* 89  italic
  text = "#cdd3e6", -- L* 85
  func = "#8fb8ff", -- L* 74  bold
  constant = "#e08a4a", -- L* 65  bold
  string = "#4fae5e", -- L* 64
  operator = "#8a93a8", -- L* 61
  comment = "#7a8098", -- L* 54  italic
  linenr = "#5a5f78", -- L* 40
  error = "#ffc4c4", -- L* 84  undercurl
  warn = "#e8b86a", -- L* 78  underline
  info = "#7fa8e0", -- L* 68  underdotted
  hint = "#5f8f84", -- L* 56  underdashed
}

-- Syntax roles: one lightness tier + style per role, applied to every group in `groups`
local syntax = {
  {
    fg = p.keyword,
    style = { "bold" },
    groups = {
      "Keyword",
      "@keyword",
      "@keyword.function",
      "@keyword.return",
      "@keyword.import",
      "@keyword.conditional",
      "@keyword.repeat",
      "@keyword.operator",
    },
  },
  {
    fg = p.func,
    style = { "bold" },
    groups = {
      "Function",
      "@function",
      "@function.call",
      "@function.method",
      "@function.method.call",
      "@function.builtin",
      "@lsp.type.method",
      "@lsp.type.function",
    },
  },
  { fg = p.string, groups = { "String", "@string" } },
  {
    fg = p.constant,
    style = { "bold" },
    groups = { "Number", "Boolean", "Constant", "@constant", "@constant.builtin" },
  },
  {
    fg = p.type,
    style = { "italic" },
    groups = {
      "Type",
      "@type",
      "@type.builtin",
      "@lsp.type.class",
      "@lsp.type.struct",
      "@lsp.type.enum",
      "@lsp.type.interface",
    },
  },
  { fg = p.text, groups = { "@variable" } },
  { fg = p.text, style = { "italic" }, groups = { "@variable.parameter", "@lsp.type.parameter" } },
  { fg = p.operator, groups = { "Operator", "@operator", "@punctuation.bracket", "@punctuation.delimiter" } },
  { fg = p.comment, style = { "italic" }, groups = { "Comment", "@comment" } },
}

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = { dark = "mocha" },
      color_overrides = {
        mocha = {
          mauve = p.keyword,
          yellow = p.type,
          blue = p.func,
          peach = p.constant,
          green = p.string,
          sky = p.operator,
          red = p.error,
          text = p.text,
          subtext1 = "#b8bfd4",
          subtext0 = "#a3abc2",
          overlay2 = p.operator,
          overlay1 = p.comment,
          overlay0 = p.linenr,
          surface2 = "#4a5070",
          surface1 = p.selection,
          surface0 = "#262a3a",
          base = p.base,
          mantle = p.mantle,
          crust = p.crust,
        },
      },
      styles = {
        comments = { "italic" },
        keywords = { "bold" },
        functions = { "bold" },
        types = { "italic" },
        numbers = { "bold" },
        booleans = { "bold" },
      },
      highlight_overrides = {
        mocha = function()
          local hl = {}
          for _, role in ipairs(syntax) do
            for _, group in ipairs(role.groups) do
              hl[group] = { fg = role.fg, style = role.style }
            end
          end
          return vim.tbl_extend("error", hl, {
            -- Editor UI
            LineNr = { fg = p.linenr },
            CursorLineNr = { fg = p.keyword, style = { "bold" } },
            CursorLine = { bg = p.cursorline },
            Visual = { bg = p.selection, style = { "bold" } },
            Search = { fg = p.base, bg = p.text },
            CurSearch = { fg = p.base, bg = p.keyword, style = { "bold", "underline" } },
            IncSearch = { fg = p.base, bg = p.keyword, style = { "bold", "underline" } },
            MatchParen = { bg = p.selection, style = { "bold", "underline" } },
            PmenuSel = { fg = p.base, bg = p.text, style = { "bold" } },
            BlinkCmpMenuSelection = { fg = p.base, bg = p.text, style = { "bold" } },
            WinSeparator = { fg = p.linenr },
            FloatBorder = { fg = p.linenr },

            -- Diffs: backgrounds step up in lightness
            DiffDelete = { fg = p.linenr, bg = "#1a1418" },
            DiffAdd = { bg = "#1f2a24" },
            DiffChange = { bg = "#232538" },
            DiffText = { bg = p.selection, style = { "bold" } },

            -- Diagnostics: lightness + underline shape
            DiagnosticError = { fg = p.error, style = { "bold" } },
            DiagnosticWarn = { fg = p.warn },
            DiagnosticInfo = { fg = p.info },
            DiagnosticHint = { fg = p.hint, style = { "italic" } },
            DiagnosticVirtualTextError = { fg = p.error, style = { "bold" } },
            DiagnosticVirtualTextWarn = { fg = p.warn },
            DiagnosticVirtualTextInfo = { fg = p.info },
            DiagnosticVirtualTextHint = { fg = p.hint, style = { "italic" } },
            DiagnosticUnderlineError = { sp = p.error, style = { "undercurl" } },
            DiagnosticUnderlineWarn = { sp = p.warn, style = { "underline" } },
            DiagnosticUnderlineInfo = { sp = p.info, style = { "underdotted" } },
            DiagnosticUnderlineHint = { sp = p.hint, style = { "underdashed" } },
          })
        end,
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mini = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "underdashed" },
            warnings = { "underline" },
            information = { "underdotted" },
          },
        },
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- "catppuccin" alone resolves to Neovim 0.12's built-in static port, which ignores these opts
      colorscheme = "catppuccin-mocha",
    },
  },
}
