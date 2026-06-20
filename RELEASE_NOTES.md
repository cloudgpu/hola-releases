# Hola 0.5.0 Release Notes

Released 2026-06-15.

This is the first public binary release of Hola, distributed through the
`cloudgpu/hola-releases` repository. It ships Debian/Ubuntu packages, Fedora/RPM
packages, Arch packages, and a generic Linux tarball for `x86_64`.

## What is new in 0.5.0

* Initial public release of the Hola agent runtime and reference applications.
* Production-readiness pass for the C11 core, including AddressSanitizer CI,
  hardened SSE endpoints, and improved verification loops.
* New `session_search` tool for querying persisted agent sessions.
* Approval callbacks so agent actions can pause for human confirmation.
* Release automation that builds Linux packages in Docker sandboxes and
  publishes them to GitHub Releases.

## Improvements

* Provider abstraction now supports any OpenAI-compatible endpoint, including
  Ollama.
* Tool registry loads plugins without recompiling the agent.
* Session persistence uses SQLite and survives across restarts.
* Retry engine and error classification are more robust under transient
  failures.

## Packaging

* Debian/Ubuntu `.deb` for amd64.
* Fedora/RPM `.rpm` for x86_64.
* Arch Linux `.pkg.tar.zst` for x86_64.
* Generic Linux tarball (`hola-0.5.0-linux-amd64.tar.gz`).

Install the latest release with:

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

On Windows, use WSL with the same installer; a native Windows zip is planned
for a future release.

## Source

Hola is developed in the private `cloudgpu/hola-ai-agent` repository. Binary
releases are published here for users and downstream packagers.
