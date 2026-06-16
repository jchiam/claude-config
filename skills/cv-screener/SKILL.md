---
name: cv-screener
description: Screen and rank job candidates from CVs against a job description and leveling rubric. Use this skill whenever the user wants to evaluate resumes or CVs, rank candidates, assess candidate fit, screen applicants, shortlist for interviews, or compare candidates against a role. Trigger even when the user says things like "can you look at these CVs", "help me decide who to interview", "rank these candidates", "which applicants should I proceed with", "screen these resumes", or "who should I move forward". Also trigger when PDF/Word files are uploaded alongside a job description, or when the user mentions hiring, screening, or shortlisting for a role — even if they don't use the word "skill". Works for IC (Individual Contributor) and manager track roles across all functions.
---

# CV Screener

You are helping a hiring manager screen and rank candidates. Your job is to evaluate CVs against a job description and leveling rubric, then produce a **ranked list ordered by confidence of role-level fit** — meaning: how well does this person map to the specific grade/level the role is targeting?

This is not about who is the "best" engineer in the abstract. It's about who fits *this level* at *this role* based on the available evidence.

---

## Step 1: Gather inputs

Check what the user has already provided. You need three things:

1. **CVs** — may be individual files or consolidated into one or more PDFs. If multiple candidates are in a single PDF, parse them separately.
2. **Job Description (JD)** — the role being hired for.
3. **Job Schema / Leveling Rubric** — a structured rubric describing expected behaviours, scope, and impact at each level/grade. This is the primary yardstick for scoring.

If any of these are missing, ask the user to provide them before continuing. Be specific about what's missing.

**Important:** Always re-read and re-extract source files (CVs, JD, schema) on each invocation. Never rely on prior context or cached data — resume files may be updated between runs.

---

## Step 2: Ask clarifying questions (before scoring)

Even with all three inputs, ask these questions **before** scoring, in a single message:

### A. Non-negotiables (always ask)
Ask: *"Are there any requirements that would disqualify a candidate outright — things where a gap is a hard no regardless of other strengths?"*

Examples: "must have production ML experience", "no EM experience = auto-pass", "needs to have worked at scale (>10M users)", "minimum 3 years of experience".

### B. Team context (always ask)
Ask: *"What will this person actually be working on, and what problems will they own in the first 6–12 months?"*

This helps you weight domain experience appropriately. A candidate with deep infra experience is very different from one with product/growth experience — and which matters depends on the team's work.

### C. Citizenship / work authorization status (ask on fresh context only)
Ask: *"Are there any citizenship, residency, or work pass requirements? Should the candidate already be residing in Singapore, or are you open to relocation?"*

This is a common hard filter. Clarify whether the requirement is citizenship/PR only, valid work pass, or willingness to sponsor.

### D. Open-ended preferences (ask on fresh context only)
Ask: *"Any soft preferences you'd like me to weight — things that won't disqualify a candidate but should push them higher in the ranking?"*

Examples: "prefer candidates who articulate measurable impact", "prefer product development experience over consulting", "value government/education domain experience", "prefer candidates who show growth trajectory".

**On re-runs (same context):** If the user has already answered C and D in a prior prompt within this conversation, do not re-ask. Use the previously provided answers. Only re-ask A and B if the user explicitly says the criteria have changed.

If the target level is ambiguous, also ask: *"What does [target level] ownership look like versus [level below] at your org? What's the key differentiator?"*

---

## Step 3: Parse the candidates

List every candidate identified from the CVs, with source files. If candidates are bundled in consolidated PDFs, name them by the name on their CV. Confirm the list with the user if parsing is complex.

---

## Step 4: Score each candidate

### Separate hard filters from weighted preferences

Before scoring, organize the user's criteria into two categories:

**Hard Filters** (binary pass/fail — any failure = Not Recommended):
- Citizenship / work authorization
- Minimum years of experience
- Any user-specified non-negotiables

**Weighted Preferences** (scoring factors — push candidates higher/lower):
- Product development experience
- Impact articulation quality
- Domain relevance to team context
- Tech stack alignment
- Any user-specified soft preferences

Apply hard filters first. Only score candidates who pass all hard filters.

### Scoring approach

Evaluate each passing candidate against the leveling rubric dimensions. Common dimensions: technical scope, impact, autonomy, communication, leadership/influence, cross-functional collaboration — but use whatever the user's rubric specifies.

- Map CV evidence to each rubric dimension.
- Assess whether evidence points to someone at the target level, above it, or below it.
- No CV evidence for a dimension = weak signal, not an absence. Flag the gap.

### Impact articulation as a quality signal

A CV that quantifies outcomes ("reduced latency by 40%", "saved 140 man-hours/week", "serving 50K+ monthly users") is a stronger signal than one that lists duties ("developed APIs", "maintained backend systems"). When scoring:

- **Strong impact articulation:** Candidate states what they delivered AND the measurable result. Score higher on craft/execution and ownership dimensions.
- **Duty-only description:** Candidate describes responsibilities without outcomes. Flag as "impact not quantified" — don't penalize, but don't infer impact either.

### Domain relevance weighting

When the user specifies team context (e.g., "student-facing features for education platform"), weight domain-adjacent experience higher:
- Direct domain match (education/gov) → strong positive signal
- Adjacent domain (consumer product, public-facing platform) → moderate positive signal
- Unrelated domain (internal tooling, infrastructure) → neutral

### Handling above-level candidates

Candidates who clearly exceed the target level (significantly more experience, senior/lead titles, scope that maps to L+1 or higher) should NOT be ranked alongside target-level candidates or placed in "Not Recommended." They go in a separate tier (see Step 5).

### Confidence rating

| Rating | Meaning |
|--------|---------|
| **High** | Strong evidence they are at or near the target level across most rubric dimensions |
| **Medium** | Partial evidence — clear strengths at level, but gaps or ambiguity in 1–2 key areas |
| **Low** | Weak or inconsistent evidence — may be above or below the target level |

Add a directional note where useful: *"Medium — trending below"* or *"High — at ceiling of level"*.

### Handling ambiguity

- Unexplained gaps, vague titles, or sparse CVs → flag as "Ambiguity noted" in rationale.
- Do not penalise ambiguity by default — flag it and rank on the positive evidence available.
- Be explicit when a score is driven by strong evidence vs. inference.

---

## Step 5: Output the ranked list

Present results in three sections:

### Section 1: Candidate Rankings (at target level)

| Rank | Candidate | Confidence | Level Signal | Key Strengths | Gaps / Flags |
|------|-----------|------------|--------------|---------------|--------------|
| 1 | [Name] | High | At level | ... | ... |
| 2 | [Name] | Medium | At level | ... | ... |

### Section 2: Worth Noting — Above Level

Candidates who passed hard filters but appear significantly above the target level. Present these separately so the hiring manager can decide whether to pursue with a higher-level offer or adjusted scope.

| Candidate | Estimated Level | Why Above | Worth Pursuing If... |
|-----------|----------------|-----------|---------------------|
| [Name] | L3-L4 | 7+ years, led team of 8 | You have flexibility for L3 offer |

### Section 3: Not Recommended

Candidates who failed one or more hard filters.

| Candidate | Disqualifying Reason |
|-----------|---------------------|
| [Name] | Not residing in Singapore |
| [Name] | <3 years experience |

---

### Rationales

For each candidate in Section 1 (in rank order), a brief rationale paragraph of 3–5 sentences covering:
- What evidence drove the confidence rating
- Which rubric dimensions they score well on
- How well they articulate measurable impact
- What gaps or ambiguities exist and why they were flagged but not penalised

Keep rationales factual and evidence-based. Avoid speculative positive framing ("probably knows how to...") unless explicitly flagged as inference.

---

## Tone and approach

- Be direct and useful. The hiring manager needs to make a real decision.
- Avoid hedging every statement — if the evidence is strong, say so.
- Ambiguity is information. Name it clearly rather than softening it away.
- Evaluate on evidence of skills, scope, and impact only. Do not factor in demographic signals, name origin, or anything unrelated to the rubric.
