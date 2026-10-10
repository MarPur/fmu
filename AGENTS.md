# Repository Guidelines

## Project Structure & Module Organization

FMU provisions a personal laptop running Ubuntu 26.04. `setup.sh` is the executable entry point: it installs packages and developer tools, updates shell profiles, and configures GNOME. `README.md` describes the project and its inspiration. There are no separate source, test, or asset directories.

Keep additions in clearly commented, tool-specific sections of `setup.sh`. Reuse the existing `apt_install`, `snap_install`, and `wget_download` helpers. Downloads are staged in `/tmp`; user binaries that need to be on PATH go in `$HOME/.local/bin`, and larger installations go in `$HOME/opt`.

## Build, Test, and Development Commands

- `bash -n setup.sh`: check Bash syntax without executing installation steps.
- `git diff --check`: detect whitespace errors before committing.
- `shellcheck setup.sh`: optionally run static analysis if ShellCheck is installed; no linter or formatter is configured in the repository.

There is no build step or application development server.

Never execute the `setup.sh` script.

## Coding Style & Naming Conventions

Use Bash, two-space indentation for new blocks, and lowercase snake_case function names. Follow existing uppercase names for installation paths and versions, such as `LOCAL_BIN` and `GO_VERSION`. Quote path expansions and preserve argument forwarding with `"$@"`.

Retain `set -exo pipefail` and use brief comments to identify installation sections. Guard shell-profile additions against duplicate entries, following existing `grep -qF` checks. Keep download architecture choices consistent with the script’s amd64/x86_64 targets.

## Testing Guidelines

No automated test framework or coverage requirement exists. Run syntax and whitespace checks for every script change. Validate installation changes on a disposable Ubuntu 26.04 desktop VM; confirm affected executables, versions, profile entries, and desktop settings. Check repeat-run behavior when changing configuration guards. Do not execute provisioning merely to validate documentation.
