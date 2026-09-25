# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A personal Neovim (≥ 0.12) configuration built on [LazyVim](https://lazyvim.github.io/) with
[lazy.nvim](https://github.com/folke/lazy.nvim). The user is **fully colorblind (achromatopsia)**. Any UI or
highlight change must tell things apart by **lightness and font or shape style** (bold, italic, underline type,
glyphs), never by hue alone.

## Architecture

- `init.lua`: entry point, `require("config.lazy")`.
- `lua/config/lazy.lua`: bootstraps lazy.nvim and loads the specs `lazyvim.plugins` and then `plugins` (this repo).
  - `defaults.lazy = false`, so custom plugins load at startup unless they set an event, keys, etc.
  - The update checker is on but silent.
  - The `gzip`, `tar`, `zip`, `tohtml` and `tutor` runtime plugins are disabled.
  - The install colorscheme is `catppuccin-mocha`.
- `lua/config/options.lua`: `relativenumber = false`, `tabstop` / `shiftwidth = 4`, `synmaxcol = 200`,
  `vim.g.autoformat = false`.
- `lua/config/keymaps.lua`: **every** custom keymap, as one `keys` table. Each entry is
  `{ mode, lhs, rhs, desc = ..., section = ... }`, and a loop sets them. The file ends with `return keys`: LazyVim
  loads it with `require`, and `scripts/check_session.lua` reads the table back from `package.loaded`.
- `lua/config/autocmds.lua`: `startinsert` when entering a `term://` buffer.
- `lua/plugins/*.lua`: one file per plugin override. LazyVim deep-merges these into its own specs.
- `lua/utils/*.lua`: plain Lua modules that keymaps call with `require("utils.x")`. Use the `LazyVim.root()` global
  for the project root; don't copy a helper into each module.
- `scripts/check.sh`: the smoke test. **Run it after every change** (see Testing changes).

### LazyVim extras (`lazyvim.json`)

- Languages: Python, Rust, Go, JSON, YAML, Markdown, Docker, Git.
- Editor: mini-files.

Enable or disable extras with `:LazyExtras`.

## Plugin overrides (`lua/plugins/`)

| File | What it does |
|---|---|
| `colorscheme.lua` | Catppuccin Mocha re-tuned for lightness. A palette table `p` at the top feeds both `color_overrides.mocha` (remaps Catppuccin's palette slots, so integrations follow) and `highlight_overrides.mocha`. Syntax groups come from the `syntax` role table (one `fg` and `style` applied to a list of `groups`; add a group to a role's list rather than writing a new line). UI, diff and diagnostic groups are listed explicitly (`vim.tbl_extend("error", ...)` fails loudly if a group appears in both). Diagnostic underline shapes: error = undercurl, warn = underline, info = underdotted, hint = underdashed |
| `blink.lua` | blink.cmp with `sources.default = { "lsp" }` only. Enter accepts, Tab / S-Tab cycle, the first item is preselected but not inserted |
| `autosave.lua` | `okuuva/auto-save.nvim`: deferred save 1000ms after `InsertLeave`; immediate save on `BufLeave`, `FocusLost` and `QuitPre`. It does **not** save on `TextChanged`, because each save triggers rust-analyzer check-on-save, nvim-lint, gitsigns and LSP didSave |
| `gitsigns.lua` | A different glyph for each change type: `+ ~ _ ‾ ≃ ┆` |
| `lsp.lua` | Appends `<leader>ss` (workspace symbols) to `opts.servers["*"].keys` from an `opts` **function**. Lazy merges list tables by index, so a plain `keys = {...}` table would overwrite LazyVim's entries |
| `snacks.lua` | The only Snacks spec:<br>• smooth scroll kept but shortened (`animate.duration = { step = 10, total = 100 }`)<br>• indent animation off<br>• explorer width 32<br>• `terminal.win.keys`: `<C-/>` / `<C-_>` hide the terminal. These keys are buffer-local, so they win over LazyVim's global terminal-mode `<C-/>` |
| `mini-files.lua` | Narrower mini.files columns |

## Custom utilities (`lua/utils/`)

### `symbols.lua`: project symbol finder (`<leader>fs`, `<leader>fS`)

A PyCharm-style *Go to Symbol* built on the Snacks picker. It doesn't use the LSP.

- **Finding definitions.** `M.finder` runs `rg --pcre2` **once**, using a list of coarse definition regexes
  (`rg_patterns`). It streams the results through `snacks.picker.source.proc`, the same approach as Snacks' grep
  source. After that, the Snacks matcher fuzzy-filters in memory.
- **Parsing lines.** `M.parse(state, file, lnum, text)` picks a language from the file extension and runs Lua
  patterns (`parse_python`, `parse_rust`, `parse_go`, `parse_js`, `parse_lua`) to get the kind and name. It returns
  `false` for false positives.
- **Finding the enclosing class.** A per-file indent stack tracks the enclosing class, `impl` or `trait`, so methods
  show as `Container.name`. Go takes the container from the method's receiver type.
- **Item fields.** Items use LSP kind names (`Class`, `Method`, `Struct`, …), so the built-in `lsp_symbol` formatter
  (with `workspace = true`) provides the icons and the filename column.
  - `rank = 1` marks test, spec, vendor and migration paths.
  - `bare` holds the lowercased name, used by the sort.
- **Sorting.** `name_first_sort`: when the query has no `.` or space, items whose own name contains the query
  characters in order come before items that only match through their container. After that come score, `rank`,
  text length and `idx`.
- **Options.** `M.pick(opts)` forwards extra Snacks options and returns the picker. `kinds = {...}` filters by kind,
  which is how `<leader>fS` works. The `hidden` / `ignored` options feed rg, so Snacks' built-in `<a-h>` / `<a-i>`
  toggles work.
- **To add a language:** add an extension to `lang_by_ext`, one or more coarse patterns to `rg_patterns`, a
  `parse_<lang>` function, and the rg `-t` type in `M.finder`.

### `cheatsheet.lua`: `<leader>?`

`M.open(keys)` renders `M.defaults`, a short static list of useful LazyVim defaults (plus `<leader>ss` and the
terminal `<C-/>`, which aren't in the keymap table), followed by the custom keys, grouped by `section` in the order
of `M.sections`. The window width fits the longest line.

### `testpath.lua`: `<leader>td`

Builds `pkg.module.Class.test_fn` from the file path relative to `LazyVim.root()`, plus the enclosing
class and function found with Treesitter.

### `import.lua`: `<leader>yi`

Asks the LSP for the definition of the word under the cursor (`textDocument/definition`), then copies a matching
import to the clipboard:
- Python: `from a.b import X`
- JS/TS: a relative path, or the package name for anything in `node_modules`
- Rust: `use crate::…` / `use std::…`

## Keymaps

- **Where they live:**
  - All custom keymaps are in the `keys` table in `lua/config/keymaps.lua`.
  - LSP-buffer keymaps go in `lua/plugins/lsp.lua`.
  - Keys that belong to a plugin window (like the terminal `<C-/>`) go in that plugin's window `keys` option.
- **When you add or rename a keymap:** give it a `desc` and a `section`, so which-key and the cheat sheet pick it up
  automatically. If it's an LSP or plugin-window key, also add it to `M.defaults` in `utils/cheatsheet.lua`.
- **Kept on purpose, although they duplicate LazyVim:** `<leader>pd` / `pi` / `pt` (same pickers as `gd` / `gI` /
  `gy`) and `<leader>ss` (workspace symbols; LazyVim's version shows document symbols). The user chose to keep them.
- `<leader>fi` uses `getcwd()`, not the project root, on purpose.

## Gotchas

- **The colorscheme must be `catppuccin-mocha`, not `catppuccin`.** Neovim 0.12 ships a built-in static
  `colors/catppuccin.vim` that shadows the plugin and ignores all of its options. `scripts/check.sh` checks this.
- **Rust uses rustaceanvim** (LazyVim rust extra), which sets `lspconfig.servers.rust_analyzer.enabled = false`.
  Configure rust-analyzer through rustaceanvim's `opts.server.default_settings`, not nvim-lspconfig.
- **LazyVim sets LSP keymaps per buffer on attach.** A global map with the same key (for example `<leader>ss`) is
  silently shadowed in LSP buffers. Use `plugins/lsp.lua`.
- **Lazy merges list-style opts by index.** When adding to a list LazyVim already fills (for example
  `servers["*"].keys`), use `opts = function(_, opts) table.insert(...) end`.
- **`:Lazy clean` / `:Lazy sync` rewrite `lazy-lock.json`** to match what's installed.

## Testing changes

- **Run `scripts/check.sh` after every change.** It takes about 5s and exits non-zero on failure.
  - `check_symbols.lua`: runs `utils/symbols.lua` over `scripts/fixture/` with the real rg arguments and compares
    the result with `scripts/fixture/expected.txt`. After an intended change to the finder, regenerate the expected
    output with `scripts/check.sh --update-symbols` and review the diff.
  - `check_session.lua`: runs inside a real nvim in a pseudo-terminal (via `script`) and checks:
    - the colorscheme name
    - that every keymap in the table is set with its desc
    - that `<leader>ss` in an LSP buffer is workspace symbols
    - that there are no startup errors (the pty's own `E1568` is ignored)
- **Headless runs** (`nvim --headless`) don't fire `UIEnter` / `VeryLazy`, so most plugins never load. For ad-hoc
  inspection, copy the pattern in `check_session.lua`: hook `User VeryLazy`, wait with `vim.defer_fn`, write results
  to a file, then `qa!`.
- **For refactors,** snapshot `nvim_get_keymap` / `nvim_buf_get_keymap` and `nvim_get_hl(0, {})` before and after,
  and diff them. Leave out `lualine_*` highlight groups, whose generated names change between runs.
- **Merged plugin options:**
  `require("lazy.core.plugin").values(require("lazy.core.config").plugins[name], "opts", false)`.
- **Highlights:** `vim.api.nvim_get_hl(0, { name = ..., link = false })`. Check contrast against the `Normal`
  background; text should be at least 4.5:1.
- **Startup profiling:** `require("lazy").stats()`, `nvim --startuptime`, or `:Lazy profile`.

## Formatting

`stylua.toml`: 2 spaces, 120 columns. Stylua is installed via Mason at `~/.local/share/nvim/mason/bin/stylua`. Run it
on changed Lua files (`stylua lua/ scripts/`), or use `<leader>cf` in Neovim.
