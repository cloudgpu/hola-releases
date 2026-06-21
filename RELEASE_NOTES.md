# Hola 0.5.11 Release Notes

Released 2026-06-21.

## Bug fixes

* `hola-coder --continue` now works as expected:
  * Every run prints its session id so you know what to continue.
  * `hola-coder --list-sessions` lists recent sessions.
  * Continuing an unknown session fails with a clear error instead of silently
    starting a fresh default task.
  * The task-plan tool now labels its ids as `Task ID:` to avoid confusion with
    session ids.

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
