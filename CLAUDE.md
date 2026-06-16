# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal Claude Code configuration. `~/.claude` is a symlink pointing here. Changes here take effect immediately in Claude Code.

## Key files

- `settings.template.json` — committed baseline for `settings.json` (no secrets). Edit this, not `settings.json`.
- `settings.json` — gitignored, generated locally via `setup-settings.sh`. May contain `ANTHROPIC_AUTH_TOKEN`.
- `plugins/installed_plugins.json` + `plugins/known_marketplaces.json` — committed; define which plugins/marketplaces are registered.
- `skills/*/` — each subdirectory is a slash command skill.

## Setup commands

```bash
# First-time setup (new machine)
./setup.sh                    # runs setup-links.sh then setup-settings.sh

# Re-sync skills to QoderWork + Qwen VSCode plugin
./setup-links.sh

# Regenerate settings.json from template
./setup-settings.sh           # requires jq; prompts for auth token + optional GovTech gt tools
```

## Settings flow

`settings.template.json` → `setup-settings.sh` → `settings.json` (gitignored).

The template uses Bedrock models via `ANTHROPIC_BASE_URL` pointed at GovTech's proxy (`api.ai.tech.gov.sg`). Model overrides map canonical Anthropic IDs to `bedrock.*` variants. Telemetry and error reporting are disabled.

## Skill structure

Each skill lives in `skills/<name>/` with a `SKILL.md` entry point. After adding a skill, run `./setup-links.sh` to symlink it into `~/.qoderwork/skills/` and `~/.qwen/skills/`.

## Git commits

Use `--no-gpg-sign` on all commits in this repo — GPG signing is not configured here.

## Permissions model

Denying: `npm publish`, `git push --force`, `git push -f`, `curl * | bash`, `npx`.  
Asking: `.env` files, credential files, SSH keys, cloud config dirs (`.aws`, `.gcp`, `.azure`), `settings.json`.  
`disableBypassPermissionsMode: "disable"` — bypass mode is off; permissions cannot be overridden at runtime.
