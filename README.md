# ~/.claude

Personal Claude Code configuration — settings, permissions, and custom skills.

This repo is the source of truth for `~/.claude`. A symlink points `~/.claude` to this directory. Skills are also synced to other AI tools (QoderWork, Qwen VSCode plugin).

## Structure

```
.
├── settings.template.json     # Committed settings baseline (no secrets)
├── setup.sh                   # macOS/Linux: full first-time setup (one command)
├── setup.bat                  # Windows: full first-time setup (one command)
├── setup-links.sh             # macOS/Linux/Git Bash: configure ~/.claude symlink + skill sync
├── setup-links.bat            # Windows: configure .claude junction + skill sync
├── setup-settings.sh          # macOS/Linux: generate settings.json from template
├── setup-settings.ps1         # Windows: generate settings.json from template
└── skills/
    ├── commit/                # /commit skill
    ├── open-pr/               # /open-pr skill
    ├── update-docs/           # /update-docs skill
    ├── apd-*/                 # APD skill suite (13 skills)
    ├── documentation-writer/  # Shared skill
    ├── refactor/              # Shared skill
    ├── security-requirement-extraction/  # Shared skill
    └── webapp-testing/        # Shared skill
```

## Settings

`settings.json` is **gitignored** — it is generated locally and may contain credentials.

`settings.template.json` is the committed baseline. It includes all non-sensitive configuration:
- Global tool permissions (allow/deny/ask lists)
- Model overrides
- Plugin and marketplace configuration

**Denied (never auto-approved):**
- `npm publish` — prevent accidental registry publishing
- `git push --force` / `git push -f` — prevent remote history destruction
- `curl * | bash` — prevent pipe-to-shell execution
- `npx` — prevent arbitrary package execution

**Allowed (auto-approved):**
- `git -C *` — run git commands in any directory without `cd`
- Read-only git inspection (`git log`, `git diff`, `git status`)
- npm introspection (`npm list`, `npm show`, `npm run`)
- GitHub CLI (`gh auth`, `gh issue`, `gh pr`)
- Web fetching from trusted domains (github.com, npmjs.com, docs.anthropic.com, unpkg.com)
- Editing files within `~/.claude/skills/`

### Generating settings.json

Run the setup script for your platform (part of `setup.sh` / `setup.bat`):

```bash
# macOS / Linux
./setup-settings.sh

# Windows (PowerShell)
./setup-settings.ps1
```

Both scripts will:
1. Copy `settings.template.json` as the base
2. Prompt for `ANTHROPIC_AUTH_TOKEN` (skippable — key omitted if blank)
3. Optionally run `gt tools configure claude-code` to inject OTEL/GovTech settings

## Skills

Skills are invoked as slash commands inside Claude Code. They are also synced to QoderWork and Qwen VSCode plugin via `setup-links.sh`.

### Core

| Skill | Command | Description |
|-------|---------|-------------|
| commit | `/commit` | Analyzes diff, splits into logical commits, derives messages from repo style |
| open-pr | `/open-pr` | Pushes branch and opens a PR via `gh pr create` with structured summary |
| update-docs | `/update-docs` | Updates README and GitHub wiki to reflect recent repo changes |

### APD Suite

| Skill | Description |
|-------|-------------|
| `apd-api-design-principles` | REST and GraphQL API design guidance |
| `apd-brainstorming` | Structured ideation before building features |
| `apd-code-reviewer` | AI-powered code review |
| `apd-create-pr` | GitLab MR creation via `glab` |
| `apd-doc-coauthoring` | Collaborative documentation writing |
| `apd-draw-io` | Draw.io diagram creation and editing |
| `apd-lint-and-validate` | Run validation after every code change |
| `apd-mermaid-expert` | Mermaid diagram creation |
| `apd-openapi-spec-generation` | OpenAPI 3.1 spec generation and validation |
| `apd-skill-creator` | Create and optimize new skills |
| `apd-systematic-debugging` | Structured debugging before proposing fixes |
| `apd-tdd` | Test-driven development workflow |

### Shared (from `~/.agents/skills/`)

| Skill | Description |
|-------|-------------|
| `documentation-writer` | Diátaxis-guided technical documentation |
| `refactor` | Surgical refactoring without behavior changes |
| `security-requirement-extraction` | Derive security requirements from threat models |
| `webapp-testing` | Playwright-based local web app testing |

## Setup

### First-Time Setup (new machine)

```bash
# macOS / Linux
git clone <repo-url> ~/claude_config
cd ~/claude_config
./setup.sh

# Windows
git clone <repo-url> %USERPROFILE%\claude_config
cd %USERPROFILE%\claude_config
setup.bat
```

`setup.sh` / `setup.bat` runs both steps in order:
1. **`setup-links`** — creates `~/.claude → this repo` symlink, then syncs all skills to `~/.qoderwork/skills/` and `~/.qwen/skills/`
2. **`setup-settings`** — generates `settings.json` from template, prompts for credentials

### Adding New Skills

1. Create the skill in `skills/my-new-skill/SKILL.md`
2. Re-run `./setup-links.sh` (or `setup-links.bat`) to sync to other tools
3. Commit: `git add skills/my-new-skill && git commit -m "feat: add my-new-skill"`

### Re-syncing Skills

```bash
# macOS / Linux
./setup-links.sh

# Windows
setup-links.bat
```

### Platform Notes

| Platform | Method | Admin Required |
|----------|--------|----------------|
| macOS/Linux | `ln -s` symlink | No |
| Windows (CMD/Git Bash) | Junction (`mklink /J`) | No |

## What's gitignored

Runtime and ephemeral state generated by Claude Code is excluded:

- `settings.json` — generated locally, may contain credentials (use `setup-settings.sh` to regenerate)
- `backups/`, `file-history/`, `sessions/`, `shell-snapshots/` — transient session data
- `cache/`, `paste-cache/`, `session-env/` — runtime caches
- `ide/`, `plans/`, `projects/`, `tasks/` — working state
- `telemetry/`, `history.jsonl` — usage logs
- `memory/` — auto-generated conversation memory
- `plugins/cache/`, `plugins/data/`, `plugins/marketplaces/` — plugin runtime (manifests are committed)
- `plugins/blocklist.json`, `plugins/install-counts-cache.json` — internal plugin state
- `.credentials.json` — auth secrets
