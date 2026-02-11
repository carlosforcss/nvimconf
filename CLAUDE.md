# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on [LazyVim](https://lazyvim.github.io/), a Neovim distribution that provides a well-structured base configuration with lazy plugin loading via [lazy.nvim](https://github.com/folke/lazy.nvim).

## Architecture

### Core Structure

- `init.lua` - Entry point that bootstraps the configuration by requiring `config.lazy`
- `lua/config/` - Core configuration files loaded by LazyVim
  - `lazy.lua` - Bootstraps lazy.nvim and sets up plugin loading
  - `options.lua` - Vim options (e.g., absolute line numbers instead of relative)
  - `keymaps.lua` - Custom key mappings
  - `autocmds.lua` - Custom autocommands
- `lua/plugins/` - Plugin configurations, each file returns a plugin spec or table of specs

### Plugin System

LazyVim loads plugins from two sources:
1. Built-in LazyVim plugins (`lazyvim.plugins`)
2. Custom plugin specs from `lua/plugins/*.lua`

Each file in `lua/plugins/` should return a plugin specification table. LazyVim automatically loads and merges these specs.

### LazyVim Extras

Enabled language and feature extras (see `lazyvim.json`):
- Languages: Python, Rust, Go, TypeScript/Angular, Astro, Docker, Terraform, SQL, YAML, JSON, Markdown, Git, Helm
- AI: Copilot (native + chat)
- Editor: mini-files

## Key Customizations

### Copilot Configuration
- Uses `zbirenbaum/copilot.lua` instead of official plugin
- Panel disabled, inline suggestions enabled with auto-trigger
- Keybindings:
  - `<C-l>` - Accept suggestion
  - `<M-]>` - Next suggestion
  - `<M-[>` - Previous suggestion
  - `<C-]>` - Dismiss suggestion

### Rust Development
- rust-analyzer configured with all features enabled and check-on-save

### Auto-save
- Configured via `Pocco81/auto-save.nvim`
- Triggers on InsertLeave and TextChanged with 135ms debounce
- Silently saves without messages

### LSP UI Enhancements
- Lspsaga provides enhanced LSP UI (peek definitions, implementations, etc.)
- Custom keymaps in `<leader>p` group:
  - `<leader>pd` - Peek Definition
  - `<leader>pi` - Peek Implementation
  - `<leader>pt` - Peek Type Definition

### Terminal
- ToggleTerm configured for floating terminal
- `<leader>tt` toggles terminal in both normal and terminal modes

### Notable Custom Keymaps
- `jj` in insert mode → Escape to normal mode
- `gd` → LSP definitions (Snacks picker override)
- `gr` → LSP references (Snacks picker override)
- `<leader>ss` → Search workspace symbols
- `<leader>td` → Copy Python dotted test path (package.module.Class.test_method format)
- `<leader>fi` → Find files in ignored src folder
- `<leader>ya` → Yank (copy) entire file to clipboard

### Editor Settings
- Absolute line numbers enabled (relative numbers disabled)

## Adding New Plugins

Create a new file in `lua/plugins/` returning a plugin spec:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- or other lazy-loading event
  opts = {
    -- plugin options
  },
}
```

## Formatting

Lua formatting is configured via `stylua.toml`:
- 2 spaces indentation
- 120 column width

Run formatting with: `:lua vim.lsp.buf.format()` or LazyVim's default `<leader>cf`

## LazyVim Commands

- `:Lazy` - Open lazy.nvim UI to manage plugins
- `:LazyExtras` - Browse and toggle LazyVim extras
- `:LazyHealth` - Check configuration health

## File Organization

When modifying this configuration:
- Add new plugins to `lua/plugins/` as separate files (one plugin or related group per file)
- Add custom keymaps to `lua/config/keymaps.lua`
- Add editor options to `lua/config/options.lua`
- Add autocommands to `lua/config/autocmds.lua`
- Enable/disable LazyVim extras through `:LazyExtras` (persisted to `lazyvim.json`)
