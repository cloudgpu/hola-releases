# Hola 0.5.16 Release Notes

Released 2026-06-22.

## What's new

* Added support for the `OPENAI_MODEL` environment variable. Model selection
  now follows this precedence:
  1. `HOLA_MODEL`
  2. `OPENAI_MODEL`
  3. `OLLAMA_MODEL`
  4. Built-in default

  This makes it easier to configure OpenAI-compatible providers with the
  conventional `OPENAI_*` variable set (`OPENAI_BASE_URL`, `OPENAI_API_KEY`,
  `OPENAI_MODEL`).

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
