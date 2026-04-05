---
name: commit
description: Commits uncommitted changes on the current branch, splitting into multiple logical commits when changes span distinct concerns.
disable-model-invocation: true
allowed-tools: Bash(git status), Bash(git diff*), Bash(git log*), Bash(git add*), Bash(git commit*), Read, Glob, Grep
---

Commit all uncommitted changes on the current branch. Follow these steps:

1. Run `git status` to see what files are modified, added, or deleted.
   - If there is nothing to commit, tell the user and stop.
2. Run `git diff HEAD` to read the full diff of all changes.
3. Run `git log --oneline -5` to understand the recent commit style and conventions in this repo.
4. Analyze the diff and group changes into logical units:
   - A logical unit is a coherent, self-contained change — e.g. a bug fix, a new feature, a refactor, a dependency update, a config change.
   - Changes to the same concern (e.g. a feature and its tests) belong in the same commit.
   - Changes to unrelated concerns (e.g. a bug fix and a style cleanup) should be separate commits.
   - If $ARGUMENTS is provided, treat it as the commit message or additional context — in this case prefer a single commit unless the split is obvious.
   - If all changes form a single coherent concern, proceed with one commit.
5. For each logical group (in dependency order — foundational changes first):
   a. Stage only the files belonging to that group using `git add <file> [<file> ...]`.
   b. Derive a commit message for that group:
      - Use the repo's existing commit style (e.g. imperative mood, prefix conventions).
      - Subject line: concise summary under 72 characters.
      - Add a short body if the group contains multiple related changes worth listing.
   c. Commit using a HEREDOC:
      ```
      git commit -m "$(cat <<'EOF'
      <subject line>

      <optional body>

      Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
      EOF
      )"
      ```
   d. If a pre-commit hook fails, report the error and stop — do not retry or amend blindly.
6. Report all resulting commit hashes and subject lines.

Important rules:
- Never commit files that look like they contain secrets (.env, credentials, private keys).
- Never use --no-verify or skip hooks.
- Do not push unless the user explicitly asks.
