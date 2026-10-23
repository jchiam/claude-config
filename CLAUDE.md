# CLAUDE.md

Global guidance for all projects. Repo-specific guidance for this config repo lives in `.claude/CLAUDE.md`.

## Slack Content

When ingesting or fetching Slack messages/threads, ALWAYS use `~/.claude/scripts/slack-fetch-thread.sh <slack-url>`. Never use WebFetch on Slack URLs (requires auth). The script reads the API token from macOS Keychain (`slack-api-token` service) and resolves user IDs to real names.

Usage: `bash ~/.claude/scripts/slack-fetch-thread.sh <slack-url> [output-slug]`
