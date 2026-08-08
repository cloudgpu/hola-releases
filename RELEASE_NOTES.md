# Hola 0.6.5 Release Notes

Released 2026-08-08.

## Bug fixes

* `hola-suggest`, `hola-explain`, and `hola-chat` now accept the `-p <profile>`
  flag to select a profile from `~/.hola/profiles.json`. Previously the flag
  was silently swallowed by the shell function's `getopts` and treated as
  part of the prompt text.

## What you get

* `hola-coder` — agentic coding assistant (loads plugins automatically)
* `hola-admin` — system administration helper
* `hola-prompt` — prompt engineering helper
* `hola-suggest`, `hola-explain`, `hola-chat` — Zsh/Bash plugin functions
* `:HolaExplain`, `:HolaFix`, `:HolaSuggest` — Vim/Neovim plugin commands

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

After installing, run `rehash` in Zsh or open a new terminal.
