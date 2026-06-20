# Hola 0.5.4 Release Notes

Released 2026-06-20.

## Bug fixes

* Fixed the Arch Linux package so the `hola-coder` and `hola-admin`
  symlinks in `/usr/bin` are actually included. Previously the package
  builder only archived regular files and dropped the symlinks, so the
  commands were not on PATH after `pacman -U`.

## What you get

* `hola-coder` — agentic coding assistant
* `hola-admin` — system administration helper
* `hola-suggest`, `hola-explain`, `hola-chat` — Zsh plugin functions
* `:HolaExplain`, `:HolaFix`, `:HolaSuggest` — Vim/Neovim plugin commands

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

After installing on Arch, run `rehash` in your current Zsh session (or open
a new terminal) so the shell discovers `hola-coder` and `hola-admin`.
