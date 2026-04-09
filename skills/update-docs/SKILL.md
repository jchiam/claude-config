---
name: update-docs
description: Updates README.md and the GitHub wiki (if present) to reflect recent changes. Reads git history for context, makes targeted edits, commits README in main repo, then prompts before committing and pushing the wiki submodule.
disable-model-invocation: true
allowed-tools: Read, Edit, Glob, Grep, Bash(git log*), Bash(git diff*), Bash(git status*), Bash(git add*), Bash(git commit*), Bash(git push*), Bash(git pull*), Bash(ls wiki*)
---

Update README.md and the GitHub wiki to reflect recent repository changes. Follow these steps exactly.

## Step 1 — Gather context

1a. If `$ARGUMENTS` is provided, treat it as a plain-language description of what changed (e.g. "added party management to R1999", "rewrote CI pipeline"). Use it as the primary focus signal. Still run the git commands below to catch anything additional.

1b. Run from the repo root:
```
git log --oneline -10
git diff HEAD~5..HEAD --stat
```
Identify what changed across recent commits. Pay attention to:
- New features or pages (`src/`, `scripts/`, `.github/workflows/`)
- Changed dependencies (`package.json`)
- Changed CI/CD pipelines (`.github/workflows/*.yml`)
- Changed DB schema (`supabase/migrations/`)
- Changed environment variables (`.env.template` if present)

1c. Build a concrete changelog list before making any edits. Do not proceed until this list is clear.

## Step 2 — Detect wiki

2a. Run `ls wiki/` to check for presence.

2b. If `wiki/` does not exist or contains no `.md` files, set **wiki = absent** and skip Steps 4 and 7.

2c. If `wiki/` exists and contains `.md` files, read `.gitmodules` to confirm a `wiki` submodule entry, then set **wiki = present**.

## Step 3 — Update README.md

3a. Read `README.md` in full.

3b. Apply targeted edits only to sections whose content is now outdated. Use this mapping:

| Section | Update when... |
|---------|----------------|
| Tech Stack Choices | A library/framework was added, removed, or its purpose changed |
| Getting Started | New env vars required, new setup steps, changed commands |
| Testing | New test types added, changed test commands or tooling |
| Deployment | Changed deployment platform, new required env vars or steps |
| Wiki section | New wiki pages added, or submodule URL changed |

3c. Preserve all badge lines, existing code blocks, and sections whose content is still accurate. Do NOT rewrite sections for style.

## Step 4 — Update wiki pages _(skip if wiki = absent)_

4a. Read all present wiki pages:
- `wiki/Home.md`
- `wiki/Data-Architecture.md`
- `wiki/Development.md`
- `wiki/Game-Trackers.md`

4b. Apply targeted edits using this mapping:

| Changed area | Wiki page(s) to update |
|---|---|
| New game or supported game | `Home.md` (Supported Games table), `Game-Trackers.md` (new section) |
| Tech stack change | `Home.md` (Tech Stack table) |
| Source directory structure change | `Home.md` (Architecture Overview) |
| New feature in existing tracker | `Game-Trackers.md` |
| New/changed DB table or migration | `Data-Architecture.md` |
| New/changed env var | `Development.md` |
| New/changed CI workflow or npm script | `Development.md` |
| New wiki page added | `Home.md` (Wiki Pages index at the bottom) |

4c. Edit only pages that are affected. Do NOT rewrite unaffected pages or sections.

## Step 5 — Commit in main repo

5a. Stage README if it was modified:
```
git add README.md
```

5b. Check `git status` to confirm what is staged.

5c. Commit using the repo's Conventional Commits style with a `docs:` prefix:
```
git commit -m "$(cat <<'EOF'
docs: update README and wiki for <one-line summary>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```
Adjust the subject if only README changed (no wiki):
- README only: `docs: update README for <summary>`

5d. If a pre-commit hook fails, report the error and stop. Do not retry or amend.

5e. **Do NOT push the main repo** unless the user explicitly asks.

## Step 6 — Report

Summarise:
- Which README sections changed (or "no README changes needed")
- Which wiki pages changed (or "wiki absent" / "no wiki changes needed")
- The README commit hash (if a commit was made)
- Note that wiki changes are staged locally in `wiki/` but have NOT been committed or pushed

## Step 7 — Prompt for wiki commit and push _(skip if wiki = absent or no wiki files changed)_

Ask the user:

> Wiki changes are ready. Commit and push the wiki submodule now?
> - **Yes** — commit inside `wiki/`, push to remote, then commit the updated submodule pointer in the main repo
> - **No** — leave wiki changes as uncommitted edits in `wiki/`

If the user says **yes** (or any affirmative), proceed:

7a. Stage only the changed wiki files:
```
cd wiki && git add <changed files>
```

7b. Commit with a plain-English message (the wiki repo does not use Conventional Commits):
```
cd wiki && git commit -m "$(cat <<'EOF'
Update docs: <one-line summary of what changed>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

7c. Push the wiki submodule — required for the GitHub Wiki UI to update:
```
cd wiki && git push
```
If push fails due to a diverged remote, run `cd wiki && git pull --rebase` first, then retry.

7d. Return to repo root and commit the updated submodule pointer:
```
git add wiki && git commit -m "$(cat <<'EOF'
docs: update wiki submodule pointer

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

7e. Report the wiki commit hash and confirm the push succeeded.

## Rules

- Never commit files that look like they contain secrets (`.env`, `.env.local`, credentials, private keys).
- Never use `--no-verify` or skip hooks.
- Never push the main repo automatically.
- When unsure whether a section needs updating, leave it unchanged rather than rewriting accurate content.
- Each Bash call that targets the wiki submodule must begin with `cd wiki &&` — do not assume the shell is already inside `wiki/`.
- Each Bash call that must run from the repo root should confirm or restore the working directory as needed.
