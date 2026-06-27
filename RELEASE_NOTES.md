# Hola 0.5.22 Release Notes

Released 2026-06-27.

## Bug fixes

* Fixed a segmentation fault during context compression (`--step` mode and
  long sessions). `hola_session_db_rotate_session()` now checks for NULL
  titles returned by SQLite before calling `strdup()`.
* Hardened `session_db.c` against NULL values in other JSON-export paths.

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
