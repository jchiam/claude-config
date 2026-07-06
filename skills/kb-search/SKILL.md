---
name: kb-search
description: |
  Search the organisation's internal knowledge base for org-specific information.
  Use when the user or you need to look up: internal API documentation, service contracts,
  architecture decisions (ADRs), coding standards, runbook procedures, deployment guides,
  service owners, GovPaaS patterns, IaC conventions, or any org-specific knowledge not
  visible in the current repository.
  Also use proactively when implementing from a spec, requirements file, or design document —
  search for related org standards and patterns before implementing each requirement.
  Do NOT use for general programming questions answerable from public documentation.
allowed-tools: Bash(moe *)
---

# Internal Knowledge Base Search

## When to Search

**Reactive** — search when the user asks about or you encounter:
- Internal APIs, service contracts, or integration patterns
- Architecture decisions (ADRs)
- Coding standards and conventions
- Runbook procedures
- Deployment guides and GovPaaS patterns
- IaC/CDKTF conventions and module usage
- Service ownership and team responsibilities

**Proactive (Spec-Driven Development)** — search automatically when:
- You are implementing from a spec, requirements file, or design document
- You are working through acceptance criteria that reference org-specific systems
- You are making architectural or infrastructure decisions that may have org standards

## How to Search

!`moe kb search --help`

Run:
```bash
moe kb search "<natural language query>" --json
```

Use specific, descriptive queries:
- Good: `"GovPaaS ECS task definition health check pattern"`
- Good: `"CDKTF module conventions for S3 buckets"`
- Bad: `"deployment"` (too broad)

### Choosing the Right Knowledge Base

| `--kb` value | What it contains | Use when |
|---|---|---|
| `code` | GitLab repos — code examples, configs, CI/CD pipelines, Terraform, READMEs | Looking for implementation examples, existing patterns, or how something is actually built |
| `internal` | Engineering handbooks (GTO/MOE) + IM8 security controls | Looking for standards, guidelines, best practices, compliance requirements, or IM8 controls |
| `document` | Confluence — technical docs, architecture guides, team/personnel info | Looking for architecture decisions, conceptual explanations, team ownership, or "who/what is X" |
| `all` | All of the above (default) | General org questions or when unsure which KB has the answer |

```bash
moe kb search "<query>" --json --kb code       # implementation examples from GitLab
moe kb search "<query>" --json --kb internal   # standards, handbooks, IM8 controls
moe kb search "<query>" --json --kb document   # architecture docs, team info (Confluence)
moe kb search "<query>" --json                 # all KBs (default)
```

**Multi-KB strategy**: When a question spans domains, run multiple targeted searches rather than one broad `all` query. For example, when implementing an ECS service:
1. `--kb internal` → "GovPaaS ECS deployment standards"
2. `--kb code` → "ECS task definition example"

This yields better results than a single `--kb all` query because each KB is searched and ranked independently.

## Interpreting Results

Each result in the JSON response contains:

| Field | Description |
|-------|-------------|
| `title` | Document or file name |
| `snippet` | The relevant content extract |
| `confidence` | Score from 0 to 1 |
| `source` | Origin: `gitlab` or `confluence` |
| `url` | Link to the original document |

**Confidence thresholds:**
- **HIGH** (> 0.7): Reliable — use directly
- **MEDIUM** (0.4–0.7): Relevant but verify with user
- **LOW** (< 0.4): Tangential — mention only if nothing better exists

## Spec-Driven Development Behaviour

When you detect you are implementing from a spec or requirements document:

1. **Before each requirement**, search the KB for related org patterns:
   - Technology-specific standards (e.g., "NestJS module conventions", "CDKTF naming")
   - Infrastructure patterns (e.g., "GovPaaS ECS service pattern", "ALB configuration")
   - Security or compliance requirements (e.g., "IM8 controls for S3")

2. **Incorporate findings** into your implementation — follow org standards over generic best practices when they exist.

3. **Cite what influenced you** — when KB results shaped your implementation choice, mention the source briefly (title + origin).

4. **Don't block on missing results** — if the KB has nothing relevant for a requirement, proceed using general best practices. Not everything is documented.

## Guidelines

1. **Search before assuming** — if the answer involves org-specific systems, check the KB first
2. **Use `--json`** — always use the JSON flag for structured, parseable output
3. **Cite sources** — when using KB content, reference the title and URL
4. **Flag low confidence** — tell the user when results are LOW confidence and may not be authoritative
5. **Say when there's nothing** — if zero results, say so explicitly rather than guessing
6. **One query at a time** — prefer focused queries over broad ones; run multiple searches if needed
7. **Don't over-search** — for general programming questions (public knowledge), skip the KB entirely
