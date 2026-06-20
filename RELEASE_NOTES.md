# Hola 0.5.7 Release Notes

Released 2026-06-20.

## Bug fixes

* `hola-coder` now reports the correct version (`0.5.7`) instead of the
  hard-coded placeholder `0.1.0`. The version is now passed from the top-level
  `Makefile` at build time.
* `hola-admin` now supports `--version`, `--help`, and `--list-tools` (`-l`)
  so you can verify the install and inspect available diagnostic tools without
  starting a full agent run.

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
