# 💤 Neovim config (LazyVim)

A personal Neovim setup built on [LazyVim](https://github.com/LazyVim/LazyVim). The main customizations:

- **High-contrast, colorblind-friendly theme.** Catppuccin Mocha is re-tuned so every syntax role has its own
  brightness level, and roles at the same level get a different font style. Diagnostics use different underline
  shapes, and git changes use different symbols, so nothing depends on hue.
- **PyCharm-style "Go to Symbol".** `<leader>fs` / `<leader>fS` find functions, methods and classes across the whole
  project. They use ripgrep and fuzzy-match on the symbol name, and don't depend on the language server.
- **Tuned for speed.** Auto-save no longer saves on every keystroke, only LSP completion is used, and smooth scrolling
  is kept short.

## Requirements

- **Neovim ≥ 0.12**
- **git**
- **[ripgrep](https://github.com/BurntSushi/ripgrep) with PCRE2** (the Homebrew build includes it). Check with
  `rg --pcre2-version`.
- **A Nerd Font** for icons. See below.
- A terminal with true color, undercurl and italics (for example Ghostty, kitty, WezTerm or iTerm2). The theme uses
  font styles and underline shapes to tell things apart.

### Nerd Font

Icons in the file explorer and UI require a [Nerd Font](https://www.nerdfonts.com). This config uses JetBrainsMono Nerd Font.

**macOS**

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Then set your terminal font to `JetBrainsMono Nerd Font`.

**Linux**

```sh
mkdir -p ~/.local/share/fonts
curl -fLo "JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv
rm JetBrainsMono.zip
```

Then set your terminal font to `JetBrainsMono Nerd Font`.

## Install

```sh
git clone <this repo> ~/.config/nvim
nvim   # lazy.nvim bootstraps itself and installs all plugins on first start
```

## Layout

```
init.lua                    entry point → require("config.lazy")
lazyvim.json                enabled LazyVim extras
lua/config/
  lazy.lua                  lazy.nvim bootstrap + setup
  options.lua               vim options
  keymaps.lua               every custom keymap, in one table (also feeds the <leader>? cheat sheet)
  autocmds.lua              autocommands
lua/plugins/                one file per plugin override
  colorscheme.lua           high-contrast Catppuccin Mocha
  blink.lua                 completion (LSP only)
  autosave.lua              auto-save.nvim
  gitsigns.lua              one symbol per git change type
  lsp.lua                   LSP-buffer keymaps (<leader>ss)
  snacks.lua                Snacks: scrolling, indent guides, terminal keys, explorer width
  mini-files.lua            mini.files window widths
lua/utils/
  symbols.lua               project symbol finder (<leader>fs / <leader>fS)
  import.lua                "yank import for symbol" (<leader>yi)
  testpath.lua              Python dotted test path (<leader>td)
  cheatsheet.lua            <leader>? window, generated from the keymap table
scripts/
  check.sh                  smoke test: run after any change
  fixture/                  sample project + expected output for the symbol finder
```

**LazyVim extras** (`lazyvim.json`): Python, Rust, Go, JSON, YAML, Markdown, Docker, Git, and mini-files.

## Custom keymaps

Press `<leader>?` in Neovim for a cheat sheet. `<leader>` is Space.

| Key | Mode | Action |
|---|---|---|
| `jj` | insert | Exit insert mode |
| `<leader>fs` | normal | Find functions / methods / classes in the project |
| `<leader>fS` | normal | Find classes / structs / interfaces / enums / types only |
| `<leader>ss` | normal | LSP workspace symbols |
| `<leader>pd` / `pi` / `pt` | normal | Peek definition / implementation / type definition |
| `<leader>fi` | normal | Find files inside the git-ignored `src/` folder |
| `<leader>yi` | normal | Copy an import statement for the symbol under the cursor (Python, JS/TS, Rust) |
| `<leader>td` | normal | Copy the Python dotted test path (`pkg.module.Class.test_fn`) |
| `<leader>ya` | normal | Copy the whole file to the clipboard |
| `<leader>tt` / `<leader>tb` | normal | Toggle floating / bottom terminal |
| `<C-/>` | terminal | Hide the current terminal |
| `<leader>?` | normal | Cheat sheet |

### Symbol finder tips (`<leader>fs`)

- Fuzzy abbreviations work: `usrsvc` finds `UserService`.
- Symbols whose own name matches come first. Add a `.` to search qualified names: `UserService.get`.
- Test, spec, vendor and migration files rank below your own code. Symbols you picked recently get a boost.
- `<a-i>` includes git-ignored folders and `<a-h>` includes hidden files.
- Supports Python, Rust, Go, JS/TS and Lua.
- It works by matching patterns line by line, not by parsing the code, so definitions split across several lines
  aren't found.

## Theme

| Role | Style | Lightness (0–100) |
|---|---|---|
| Keywords | **bold** | 94 |
| Types | *italic* | 89 |
| Text / variables (parameters *italic*) | normal | 85 |
| Functions / methods | **bold** | 74 |
| Numbers / constants | **bold** | 65 |
| Strings | normal | 64 |
| Operators / punctuation | normal | 61 |
| Comments | *italic* | 54 |

- **Diagnostics:** errors get a wavy underline, warnings a straight one, info a dotted one and hints a dashed one.
- **Git signs:** `+` added, `~` changed, `_` deleted, `≃` changed and deleted, `┆` untracked.
- **Tweaking:** every color is defined once in the table at the top of `lua/plugins/colorscheme.lua`. Moving an entry
  by about 5 lightness points is enough to separate two roles.

## Adding a keymap

Add an entry to the `keys` table in `lua/config/keymaps.lua`:

```lua
{ "n", "<leader>xx", function() ... end, desc = "What it does", section = "Editor" },
```

The `desc` appears in which-key and in the `<leader>?` cheat sheet (sections: Navigation, Find, LSP, Editor,
Terminal). Keymaps that should only exist in buffers with a language server go in `lua/plugins/lsp.lua` instead.

## Checking the config

```sh
scripts/check.sh
```

This checks that:
- the symbol finder still gives the expected results on `scripts/fixture/`
- a real Neovim session starts without errors, with the right colorscheme
- every keymap in the table is set
- `<leader>ss` works in LSP buffers

If you change the symbol finder on purpose, regenerate the expected output with `scripts/check.sh --update-symbols`.

## Managing the config

- `:Lazy`: plugins (update, sync, profile)
- `:LazyExtras`: enable or disable LazyVim extras
- `:LazyHealth` / `:checkhealth`: diagnose problems
