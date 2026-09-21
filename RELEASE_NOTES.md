# Hola 1.0.6 Release Notes (unreleased)

## Delegation fixes

* The built-in `codex` and `claude` profiles now read `workers` / `delegate`
  from a `profiles.json` entry of the same name, so Codex can be a master
  without redefining the profile.
* `delegate` tool argument `max_tokens` renamed to `token_budget` with a
  description that says it is a total budget, not an output length (models
  were passing 6000 and starving the worker).
* A worker stopped by its token budget now returns a clean
  `budget_exhausted` report instead of a libcurl abort error.
* Website: blog post and tutorial live at `/blog/master-worker-delegation`
  and `/agent/hola-ai-agent/tutorials/master-worker`. Content must be added
  to `website/src/content/...` (not `hola/docs/`) to reach the site.

# Hola 1.0.9 Release Notes

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
5. Bump the version the tutorial names ("hola 1.0.6 or newer") if the
   release number differs (website: `website/src/content/...master-worker*`).
6. The website is the separate `website` repo, deployed by `full-release.sh`
   via `npm run deploy`; `hola/docs/` is not published anywhere.

# Hola 1.0.5 Release Notes

* Installer now wires `HOLA_PLUGIN_DIR`, links `~/.hola/plugins`, fixes execute bits,
  and on macOS clears Gatekeeper quarantine + ad-hoc codesigns binaries.
* New `hola-update` helper for user-space upgrades (`~/.local/hola`).
* `hola-coder`/`hola-admin` resolve the real executable path so plugins load via symlinks.

Released 2026-09-21.

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
