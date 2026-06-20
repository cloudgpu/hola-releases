# Hola 0.5.2 Release Notes

Released 2026-06-20.

## Bug fixes

* Fixed the Zsh plugin so a stale `HOLA_BIN` path (e.g. an old source build
  directory) is automatically replaced with a working `hola-coder` binary.
  The plugin now searches, in order: the sibling source build directory,
  `hola-coder` on `PATH`, `/opt/hola/foundation_apps/hola-coder/bin/hola-coder`,
  and `/usr/local/bin/hola-coder`.
* Suppressed job-control messages (`[2] 3893631`, `+ exit 127`) that appeared
  in interactive shells while the spinner was running.

## Recent changes in 0.5.x

* 0.5.1 — surfaced `hola-coder` errors instead of silently discarding stderr.
* 0.5.0 — first public binary release of the Hola agent runtime.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```
