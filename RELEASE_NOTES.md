# Hola 0.5.3 Release Notes

Released 2026-06-20.

## Packaging changes

* Removed the `hola-agent` demo binary from the install package.
  Only the two user-facing command-line tools are installed now:
  * `hola-coder` — agentic coding assistant
  * `hola-admin` — system administration helper

## Recent fixes

* 0.5.2 — automatic fallback for stale `HOLA_BIN` paths and suppression of
  job-control messages in the Zsh plugin.
* 0.5.1 — surfaced `hola-coder` errors instead of silently discarding stderr.
* 0.5.0 — first public binary release.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

After installing, make sure you have an OpenAI-compatible endpoint set
(`OLLAMA_BASE_URL`, `OPENAI_BASE_URL`, or `OPENAI_API_KEY`) and run either
`hola-coder` or `hola-admin`.
