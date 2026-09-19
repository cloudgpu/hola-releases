# Hola 1.0.5 Release Notes (unreleased)

## Master / worker delegation

A master agent on a strong model can hand sub-tasks to worker agents on
cheaper profiles (for example a local Ollama model). Workers share the tools
and project, run in their own sessions, and return a short report the master
validates. Off unless a profile lists `workers` or `--worker <profile>` is
passed; the default flow is unchanged.

* New core module `hola_core/src/subagent.c` (`hola/subagent.h`).
* New plugin `delegate.so` with `delegate`, `delegate_parallel`,
  `delegate_review`. Registers nothing unless `HOLA_WORKERS` is set.
* Profile fields `workers`, `role`, `delegate.{max_turns,max_tokens,default_mode}`.
* hola-coder: `--worker`, `/workers`, `/worker <name>`, nested worker
  rendering, worker token line at exit, `HOLA_DELEGATE=0` kill switch.
* hola-gateway-d picks up `workers` from its profile.
* Worker sessions carry `parent_session_id` and source `<src>:worker`.
* `hola_profile_apply_to_config_ex()` (no env export) for secondary configs.

Docs: `docs/delegation.md`, tutorial `docs/tutorials/master-worker.md`,
blog `docs/blog/master-worker.md`.

## Release checklist for this feature

1. `make test` (includes `test_subagent`) and `make` clean under `-Werror`.
2. Smoke: `hola-coder --list-tools | grep -c delegate` prints 0 with no
   workers configured and 3 with `--worker <profile>`.
3. Smoke: one real delegated run with a local worker
   (`hola-coder --new --worker muse "Delegate to a worker: ..."`), check
   `--list-sessions` shows the worker row with `parent`.
4. Installer: `delegate.so` ships with the other coder plugins
   (`make install` and `make-install-local.sh` both copy it).
5. Bump the version the tutorial names ("hola 1.0.5 or newer") if the
   release number differs.
6. Publish `docs/` (blog entry is already listed in `docs/blog.md`).

# Hola 1.0.5 Release Notes

* Installer now wires `HOLA_PLUGIN_DIR`, links `~/.hola/plugins`, fixes execute bits,
  and on macOS clears Gatekeeper quarantine + ad-hoc codesigns binaries.
* New `hola-update` helper for user-space upgrades (`~/.local/hola`).
* `hola-coder`/`hola-admin` resolve the real executable path so plugins load via symlinks.

Released 2026-09-19.

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
