# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Requirements

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

