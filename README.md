# ~/.claude

Personal Claude Code configuration — settings, permissions, and custom skills.

This repo is the source of truth for `~/.claude`. A symlink points `~/.claude` to this directory. Skills are also synced to other AI tools (QoderWork, Qwen VSCode plugin).

## Structure

```
.
├── settings.template.json     # Committed settings baseline (no secrets)
├── setup.sh                   # macOS/Linux/WSL: full first-time setup
├── setup-links.sh             # macOS/Linux/WSL: configure ~/.claude symlink + skill sync
├── setup-settings.sh          # macOS/Linux/WSL: generate settings.json from template
├── statusline-command.sh      # Status line feature (bash + jq + git)
└── skills/
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

Run the setup script (part of `setup.sh`):

```bash
./setup-settings.sh
```

This will:
1. Copy `settings.template.json` as the base
2. Prompt for `ANTHROPIC_AUTH_TOKEN` (skippable — key omitted if blank)
3. Auto-configure `statusLine` with the correct path for this machine
4. Optionally run `gt tools configure claude-code` to inject OTEL/GovTech settings

## Skills

Skills are invoked as slash commands inside Claude Code. They are also synced to QoderWork and Qwen VSCode plugin via `setup-links.sh`.

### Core

| Skill | Command | Description |
|-------|---------|-------------|
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

### macOS / Linux / WSL

```bash
git clone <repo-url> ~/claude_config
cd ~/claude_config
./setup.sh
```

`setup.sh` runs both steps in order:
1. **`setup-links.sh`** — creates `~/.claude → this repo` symlink, syncs skills to `~/.qoderwork/skills/` and `~/.qwen/skills/`
2. **`setup-settings.sh`** — generates `settings.json` from template, prompts for credentials

### Windows (PowerShell)

Clone the repo, then run the following steps in PowerShell.

**Step 1: Create junction** (run as Administrator, or with Developer Mode enabled)

```powershell
$repo = "$env:USERPROFILE\claude_config"
$claude = "$env:USERPROFILE\.claude"

if (Test-Path $claude) { Remove-Item $claude -Force -Recurse }
New-Item -ItemType Junction -Path $claude -Target $repo
```

**Step 2: Sync skills** (repeat after adding new skills)

```powershell
$skillsDir = "$env:USERPROFILE\claude_config\skills"
$targets = @("$env:USERPROFILE\.qoderwork\skills", "$env:USERPROFILE\.qwen\skills")

foreach ($targetDir in $targets) {
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
    foreach ($skill in (Get-ChildItem $skillsDir -Directory)) {
        $link = Join-Path $targetDir $skill.Name
        if (Test-Path $link) { Remove-Item $link -Force -Recurse }
        New-Item -ItemType Junction -Path $link -Target $skill.FullName -Force | Out-Null
    }
}
Write-Host "Skills synced."
```

**Step 3: Generate settings.json**

```powershell
$repo = "$env:USERPROFILE\claude_config"
$config = Get-Content "$repo\settings.template.json" -Raw | ConvertFrom-Json

# Set auth token (press Enter to skip)
$token = Read-Host "ANTHROPIC_AUTH_TOKEN (Enter to skip)"
if ($token) {
    $config.env | Add-Member -NotePropertyName "ANTHROPIC_AUTH_TOKEN" -NotePropertyValue $token -Force
}

# Optional: run gt tools configure claude-code after writing
$config | ConvertTo-Json -Depth 20 | Set-Content "$repo\settings.json" -Encoding UTF8
Write-Host "settings.json written."
```

### Status Line (optional, macOS/Linux only)

`statusline-command.sh` provides an agnoster-style status line showing directory, git branch, model, and context usage. Requires `bash` + `jq` + `git`. Auto-configured by `setup-settings.sh`.

To add manually (e.g. after `gt tools configure` overwrites settings.json), add to `settings.json`:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"/path/to/claude_config/statusline-command.sh\""
}
```

> **Windows:** Claude Code does not support command-type statusLine on Windows.

### Adding New Skills

1. Create the skill in `skills/my-new-skill/SKILL.md`
2. Re-sync: `./setup-links.sh` (macOS/Linux) or re-run Step 2 above (Windows)
3. Commit: `git add skills/my-new-skill && git commit -m "feat: add my-new-skill"`

## Plugins

Plugins extend Claude Code with additional capabilities. Plugin state is managed in `plugins/`.

### Installed

| Plugin | Marketplace | Description |
|--------|-------------|-------------|
| `code-simplifier` | `claude-plugins-official` | Reviews changed code for reuse, quality, and efficiency |
| `caveman` | `caveman` | Ultra-compressed communication mode to reduce token usage |

### Marketplaces

| Marketplace | Source |
|-------------|--------|
| `claude-plugins-official` | `anthropics/claude-plugins-official` (GitHub) |
| `caveman` | `JuliusBrussee/caveman` (GitHub) |

`plugins/installed_plugins.json` and `plugins/known_marketplaces.json` are committed — they define which plugins and marketplaces are registered. Plugin binaries (`plugins/cache/`) and runtime data (`plugins/data/`, `plugins/marketplaces/`) are gitignored.

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
