# Hola 1.1.4 Release Notes

## Windows builds are published again

Every tagged release since v1.0.4 built a working Windows zip and then threw
it away. The job uploaded a CI artifact before publishing to the releases
repo; once the Actions artifact storage quota was hit that upload failed and
the publish step was skipped, so the run went red with a good build inside
it. The release upload now runs first and the artifact copy is last,
non-blocking, and expires after 7 days.

* `scripts/install.ps1` used `($env:HOLA_VERSION -or '<version>')` for its
  parameter defaults. `-or` is a logical operator in PowerShell: it returns
  a boolean, so `$Version` was the string "True" and every download 404'd
  into the WSL fallback. Defaults now use `if`/`else`, and a leading `v` in
  `HOLA_VERSION` is accepted.
* A new CI step parses `install.ps1` on a Windows runner and asserts the
  defaults resolve, so this cannot ship again.
* `scripts/full-release.sh` bumps the new default form and refuses to run if
  it cannot find exactly one match, instead of silently leaving a stale
  version behind.
* `gateway-ci` artifacts now expire (7 days for the 33 MB image tarball, 14
  for the small ones). That artifact, kept 90 days by default, is what
  filled the quota.

Install on Windows, in PowerShell:

    irm https://cloudgpu.io/install.ps1 | iex

## Website

* The install command on cloudgpu.io detects Windows visitors and shows the
  PowerShell line instead of the `curl | sh` one, with a link to switch
  platforms by hand.

Released 2026-09-26.

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
