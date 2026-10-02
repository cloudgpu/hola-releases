# Hola 1.10.0 Release Notes

## Prompts sized from the model profile, and caching that works

* Profiles take `context_length` and `request_token_budget`. The per-request
  prompt cap defaults to 16,000 tokens (never above the model's window); a
  profile or `HOLA_REQUEST_TOKEN_BUDGET` raises or lowers it. Hot history,
  pinned files, the conversation thread and the state frame are shares of that
  budget, and small budgets scale the floors down instead of overrunning.
* Spilling to the cold store happens in batches (down to 60% of the budget)
  so the prompt prefix stays byte-identical between spills.
* Prompt-cache breakpoints now sit on the last stable message. The per-turn
  `§state` frame is marked `volatile_tail` and is never a breakpoint, so a
  prefix is no longer written to the cache every request and never read back.
  On Haiku 4.5 through OpenRouter a measured 8-call run served 68% of its
  prompt from cache. Haiku will not cache a prefix under 4,096 tokens.
* Anthropic `input_tokens` excludes cache reads and writes; the recorded
  prompt size now includes them, so usage and budgets are correct.
* Tool selection is frozen after the first build and tool-search leases last
  32 turns, so the tool list (which precedes the messages) stops changing.

## Streaming is real, thinking is separate

* OpenAI-compatible and Responses streams are parsed as they arrive. Before,
  every reasoning and text delta reached the console in one batch after the
  whole HTTP response had finished.
* Inline `<think>…</think>` (and a bare `…</think>`, or an unclosed
  `<think>`) is split out of the answer before any tool-call extraction, so a
  call drafted while thinking is never executed and thinking is not re-sent.
* `hola-coder -i` shows the phase: `◌ waiting for model`, a live
  `⋯ thinking 12s · ~330 tok`, `⚙ ran 1.2s` after each tool, and a closing
  line with thought / worked / waited totals. The banner shows the wire API
  (`chat completions`, `responses` or `anthropic messages`).

## Reasoning

* Adaptive reasoning: with a profile `reasoning_strength` and the local Laya
  decision model available, a step that needs no deep thinking is lowered to
  `reasoning_direct` (default `minimal`) for that request only.
  `HOLA_ADAPTIVE_REASONING=0` turns it off.
* One resolver sends the level on every API: `reasoning_effort` on Chat
  Completions and `reasoning.effort` on Responses (which sent nothing before).
* `disable_thinking` is documented for what it is: a prompt-template switch
  for Qwen-style local models, not an API setting.

## Plans and project roots

* A saved plan appears in `§state` only after a plan tool has run in the
  session (or the resumed history used one). A stale plan on disk is no
  longer adopted and executed in response to "hi".
* `/tmp`, `/var/tmp` and `/dev/shm` are never a project root, even with a
  stray `.hola` in them.

## Removed: small-model workarounds

* The "I will / Let me" and short-"Done." reply detectors (including the
  reasoning-field check), the plan-only nudge text, the `nudge_style`
  variants and the model-name prompt blocks are gone. A reply is incomplete
  only when it is empty. Profiles that still list `nudge_style` are fine; the
  key is ignored. Text-tool-call parsers (xml, json, hermes, qwen) stay.

## Platform builds

* FreeBSD: the include path is no longer dropped after `override CFLAGS`,
  the cancel flag is a `sig_atomic_t` (`long` on FreeBSD), and the HPL
  tool-table tests initialize their table. `scripts/test-freebsd-build.sh`
  runs a clean build and test on the VM.
* Windows: the Laya plugin no longer trips `-Werror=address` on MSYS, where
  `dli_fname` is an array. The vcpkg cache is now saved even when a later step
  fails; a job that always failed after the ~25 minute ICU build never saved
  it, which is why every run took so long.
* Termux: ICU is installed for the Laya bridge.
* macOS: `st_mtim` is portable (fixed after v1.9.0).
* `scripts/full-release.sh` no longer waits for the Windows build; the
  workflow verifies and uploads the zip itself. `HOLA_WAIT_WINDOWS=1`
  restores the wait.

Released 2026-10-02.

# Hola 1.9.0 Release Notes

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

Install on Windows, in PowerShell (download, read, then run; piping the
script into `iex` trips antivirus heuristics):

    Invoke-WebRequest https://cloudgpu.io/install.ps1 -OutFile install.ps1
    .\install.ps1

## Website

* The install command on cloudgpu.io detects Windows visitors and shows the
  PowerShell line instead of the `curl | sh` one, with a link to switch
  platforms by hand.

Released 2026-10-02.

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
