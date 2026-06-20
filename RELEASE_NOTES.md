# Hola 0.5.1 Release Notes

Released 2026-06-20.

This is a bug-fix release for the Hola binary distribution.

## Bug fixes

* Fixed `hola-chat` in the Zsh plugin so that `hola-coder` errors are
  surfaced instead of being silently discarded. Previously, when no model
  endpoint was configured, the command would return an empty response.
* Fixed `_hola_run_with_spinner` so the background process exit code is
  preserved instead of being lost when stderr is not a TTY.

## What is new in 0.5.x

* First public binary release of the Hola agent runtime and reference
  applications.
* Production-readiness pass for the C11 core, including AddressSanitizer CI,
  hardened SSE endpoints, and improved verification loops.
* `session_search` tool for querying persisted agent sessions.
* Approval callbacks for high-risk actions.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```
