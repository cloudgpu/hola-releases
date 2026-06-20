# Hola 0.5.6 Release Notes

Released 2026-06-20.

## Bug fixes

* `hola-coder` now auto-detects its installed plugin directory when
  `HOLA_PLUGIN_DIR` is not set. Previously it only looked in `./plugins`
  relative to the current working directory, so users who installed the
  package had to set `HOLA_PLUGIN_DIR` manually before it could write or
  edit files.
* Silenced harmless compiler warnings about ignored `getcwd` return values
  in the `hola-zsh` and `hola-vim` example plugins.

## What you get

* `hola-coder` — agentic coding assistant (now loads its plugins automatically)
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
