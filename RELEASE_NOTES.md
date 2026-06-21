# Hola 0.5.15 Release Notes

Released 2026-06-21.

## Bug fixes

* Fixed heap corruption caused by unchecked `snprintf` growth in several
  components:
  * `hola-coder` tool output formatting (`coder_tools` plugin).
  * Context compression in the core agent loop.
  * System prompt and environment hint builders in `prompt_builder.c`.
  These changes eliminate random crashes such as
  `*** buffer overflow detected ***` and `double free or corruption`.

## What you get

* `hola-coder` — agentic coding assistant (loads plugins automatically)
* `hola-admin` — system administration helper
* `hola-suggest`, `hola-explain`, `hola-chat` — Zsh/Bash plugin functions
* `:HolaExplain`, `:HolaFix`, `:HolaSuggest` — Vim/Neovim plugin commands

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

After installing, run `rehash` in Zsh or open a new terminal.
