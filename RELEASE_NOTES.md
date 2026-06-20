# Hola 0.5.8 Release Notes

Released 2026-06-20.

## Bug fixes

* `scripts/install.sh` now updates an existing `hola-zsh.plugin.zsh` source line
  in `~/.zshrc` when the install prefix changes (for example, upgrading from a
  source build to a package install, or moving between `/opt/hola` and
  `~/.local/hola`). Previously the installer left a stale source path in place,
  so `hola-suggest`, `hola-explain`, and `hola-chat` failed to load after an
  upgrade.

## What you get

* `hola-coder` — agentic coding assistant (loads plugins automatically)
* `hola-admin` — system administration helper
* `hola-suggest`, `hola-explain`, `hola-chat` — Zsh plugin functions
* `:HolaExplain`, `:HolaFix`, `:HolaSuggest` — Vim/Neovim plugin commands

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

After installing, run `rehash` in Zsh (or open a new terminal) and then:

```sh
hola-coder "write a hello world python program"
```
