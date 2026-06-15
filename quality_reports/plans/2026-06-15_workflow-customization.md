# Plan: Adapt Claude Code Academic Workflow for the Dissertation

**Status:** APPROVED (2026-06-15)
**Date:** 2026-06-15
**Plan-mode draft:** `quality_reports/plans/swirling-forging-robin.md` (kept for traceability)

---

## Context

This repo is a fork of `pedrohcgs/claude-code-my-workflow`, a lecture-and-paper academic workflow template. The user is starting a PhD dissertation in political science on **foreign aid competition between the United States and China** — a ~3-paper hybrid (between traditional book and pure 3-paper). The template ships heavily lecture-oriented (Beamer + Quarto RevealJS mirror, palette sync, `/create-lecture`, GitHub Pages deploy, etc.), and its `CLAUDE.md` and `WORKFLOW_QUICK_REF.md` still carry placeholder text. `MEMORY.md` carries ~170 lines of the upstream maintainer's v1.5–v1.9 release-cycle wisdom, none of which is the user's project memory.

Goal: turn the fork into a dissertation working repo — paper-first, with lecture infra dormant — without breaking skill internals or making future upstream merges painful. Decisions already settled with the user:

| Decision | Choice |
|---|---|
| Lecture infrastructure | **Light repurpose** — keep `Slides/` dir as-is; CLAUDE.md reframes it as "talks/conferences"; lecture-specific skills marked DORMANT in docs only |
| MEMORY.md upstream content | **Prune to dissertation-relevant** — keep verification, plan-first, drift, cross-artifact, model-routing, CoVe lessons; drop release-cycle/audit history |
| Paper layout | **Self-contained per-paper directories** — `Papers/paperN_<slug>/{manuscript.tex, scripts/R/, _outputs/, figures/, tables/, README.md}` |
| Paper slugs | **TBD** — scaffold as `paper1_TODO/`, `paper2_TODO/`, `paper3_TODO/`; rename when titles firm up |

User-stated working preferences (saved to auto-memory already):
- Structured, precise, rigorous collaboration.
- Visuals **publication-ready by default**, no draft intermediates.
- Plan-first → contractor mode after approval; more check-ins in the first few sessions.
- Workflow must remember decisions and learn from corrections.

---

## Phases

### Phase 1 — Memory + configuration text (low risk, no structural change)

**1.1 Prune `MEMORY.md`.** Keep these sections (rewrite headings to be dissertation-framed, not template-framed):

- `## Workflow Patterns` — spec-then-plan, plans-on-disk, context survival.
- `## Verification Architecture (three patterns)` — critic-fixer / cross-artifact / CoVe. Foundational; do not drop.
- `## Plan→Bypass Framing` — safety boundary clarification.
- `## Privacy in Diagnostic Skills` — relevant if `/permission-check` is invoked.
- `## Claim-vs-Reality Framing` — anti-overclaim discipline.
- v1.9 entries on: model routing 70/20/10, HIGH-WARN gate-refuse, five-critic isolated voting (memory promotion), variance reporting for `--peer`, provenance YAML.

Drop: drift-prevention / surface-sync / count-drift (these guard the template's docs, not a dissertation); release-cycle dogfooding lessons; skill-creation framing; v1.5–v1.8 PR-specific incidents.

Add a one-paragraph preamble: this file is the dissertation's working memory; auto-memory lives in `~/.claude/projects/-Users-hasaanparker-my-project/memory/`; new `[LEARN]` entries go at the bottom under a new `## Project Learnings — Foreign Aid Competition Dissertation` section, which starts seeded with two entries from this kickoff:

- `[LEARN:workflow] Plan-first → contractor after approval; throttle check-ins down once user calibrates to the workflow (~5 sessions in).`
- `[LEARN:visuals] Figures + tables must be publication-ready by default. No draft-quality intermediates.`

Target end-state: MEMORY.md drops from ~170 lines to ~80–100 lines.

**1.2 Fill `CLAUDE.md` placeholders.**

- Project: **"Foreign Aid Competition: US–China"** (working title — flag for user to refine).
- Institution: leave as `[YOUR INSTITUTION]` with a TODO inline comment — user supplies later.
- Field: add "Political Science / IR" line near the top.
- Folder Structure block: replace the lecture-centric tree with the dissertation tree (`Papers/paperN_<slug>/` shown explicitly; `Slides/` annotated "(job talks / conference decks; dormant unless invoked)").
- "Skills Quick Reference" → reorder and re-label as **"Primary Workflows (dissertation)"** with:
  - **Empirical:** `/data-analysis` `/did-event-study` `/diagnose` `/audit-reproducibility` `/replication-package` `/capture-environment` `/power-analysis` `/disclosure-check` `/simulation-study`
  - **Research / writing:** `/lit-review` `/research-ideation` `/interview-me` `/preregister`
  - **Paper review + revision:** `/review-paper` (incl. `--peer` and `--variance`) `/seven-pass-review` `/review-r` `/verify-claims` `/proofread` `/humanize` `/respond-to-referees` `/submission-disclosures`
  - **Meta / workflow:** `/commit` `/learn` `/checkpoint` `/context-status` `/compress-session` `/promote-memory`
  - **Dormant (talks-only):** `/create-lecture` `/qa-quarto` `/translate-to-quarto` `/slide-excellence` `/pedagogy-review` `/respond-to-eval` `/syllabus` `/scaffold-exercises` `/deploy` `/extract-tikz` `/new-diagram` — invoke only when prepping a job talk or conference slide deck.
- Delete the "Beamer Custom Environments" and "Quarto CSS Classes" placeholder tables (lecture-specific; reintroduce when first talk is built).
- Replace "Current Project State" lecture table with a **Paper Progress** table — rows for paper1/paper2/paper3 with columns `Slug | Stage (idea/draft/under review) | Manuscript file | Lead R script`.

**1.3 Fill `.claude/WORKFLOW_QUICK_REF.md` "Non-Negotiables" + "Preferences".** Concrete values:

- Paths: `here::here()` in R; relative paths in LaTeX (use `\graphicspath{}` for figures).
- Seed: `set.seed(20260615)` (or paper-level seed defined at top of `01_load.R`) — never inline mid-script.
- Figures: PDF (vector) for manuscript inclusion; ≥300 DPI PNG only when raster is unavoidable; white background; consistent ggplot2 theme (placeholder; pick when first figure is built).
- Tables: gt or kableExtra → LaTeX via `\input{tables/<name>.tex}`; no manual copy-paste of numbers.
- Tolerance: 1e-6 default for point-estimate reproducibility; flag near-misses (within 1e-4) for manual review.
- Visuals: **publication-ready by default**; no draft intermediates.
- Reporting: concise bullets; detail on request.
- Replication: strict; near-miss = flag, not auto-pass.
- Session logs: always (post-plan, incremental, end-of-session).

**1.4 Replace `Bibliography_base.bib` example entries** with a 10-line header explaining the AuthorYear_keyword convention; leave it ready for the user's first real entry (Zotero export, manual, etc.).

### Phase 2 — Paper scaffolding (structural)

**2.1 Create three self-contained paper directories** under `Papers/`:

```
Papers/
├── paper1_TODO/
│   ├── manuscript.tex          # stub with title, abstract, sections placeholders
│   ├── scripts/R/              # 00_run_all.R + 01..05 (copy pattern from scripts/R/)
│   ├── _outputs/.gitkeep       # R intermediate outputs (.rds)
│   ├── figures/.gitkeep        # PDF figures sourced into manuscript
│   ├── tables/.gitkeep         # LaTeX table fragments
│   └── README.md               # 1-page paper-level overview
├── paper2_TODO/                # same shape
└── paper3_TODO/                # same shape
```

Each `manuscript.tex` uses `\input{../../Preambles/header.tex}` for shared formatting; each is independently compilable (the user can submit any one paper without dragging the others). `Bibliography_base.bib` is shared from repo root via `\bibliography{../../Bibliography_base}`.

**2.2 Move the existing top-level `scripts/R/` numbered workflow** into `Papers/paper1_TODO/scripts/R/` (it's currently a generic example — repurpose for paper 1). Leave top-level `scripts/` for repo-wide tooling (`quality_score.py`, `validate-setup.sh`, etc.) only.

**2.3 Add `Papers/README.md`** — one-paragraph overview of the three-paper structure, naming convention, and how cross-artifact review works inside each paper directory.

### Phase 3 — Repo-level docs (medium risk, partially destructive)

**3.1 Archive the upstream `README.md`.** Move to `quality_reports/archive/UPSTREAM_README.md`. Write a fresh, short `README.md`:

- Project title + 2-sentence dissertation summary.
- Layout (Papers/, Slides/ dormant, scripts/, Bibliography_base.bib).
- How to compile a paper (3-pass XeLaTeX).
- Pointer to `CLAUDE.md` for AI-workflow context.
- Attribution to the upstream template at the bottom.

**3.2 Leave `CHANGELOG.md` and `TROUBLESHOOTING.md` in place** but unmodified — they are upstream history, useful as reference. (Optional follow-up: move both to `quality_reports/archive/` if they become noise.)

**3.3 Verify `.vscode/settings.json`** matches the v1.8.0 lesson (key is `allowDangerouslySkipPermissions`, no `claudeCode.` prefix). Read-only check first; fix only if wrong.

### Phase 4 — Kickoff session log + verification

**4.1 Create `quality_reports/session_logs/2026-06-15_workflow-kickoff.md`** using `templates/session-log.md`. Capture: kickoff date, goal (adapt template for dissertation), decisions taken, deferred items.

**4.2 Verification pass:**
- `grep -rn "YOUR PROJECT NAME\|YOUR INSTITUTION\|YOUR PATH\|YOUR SEED\|YOUR FIGURE\|YOUR COLOR\|YOUR TOLERANCE\|\[your-env\]\|\[\.your-class\]"` in repo root must return only intentional TODO markers.
- `cd Papers/paper1_TODO && TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex` compiles the stub cleanly.
- `MEMORY.md` line count ≤ 100 (was ~170).
- All preserved `[LEARN]` entries still resolve their cross-references.

---

## Files Modified (summary)

| Path | Action |
|---|---|
| `MEMORY.md` | Prune to ~80–100 lines, reframe as dissertation memory, seed 2 user `[LEARN]`s |
| `CLAUDE.md` | Fill placeholders, reorganize skills section, replace lecture table with paper table, drop placeholder env tables |
| `.claude/WORKFLOW_QUICK_REF.md` | Fill non-negotiables + preferences |
| `Bibliography_base.bib` | Strip examples, keep header convention |
| `README.md` | Archive upstream; write fresh short dissertation README |
| `Papers/paper{1,2,3}_TODO/**` | Create (manuscript.tex stub, scripts/R skeleton, _outputs/, figures/, tables/, README.md) |
| `Papers/README.md` | Create — paper-set overview |
| `scripts/R/**` | Move to `Papers/paper1_TODO/scripts/R/` |
| `quality_reports/archive/UPSTREAM_README.md` | New (moved from `README.md`) |
| `quality_reports/session_logs/2026-06-15_workflow-kickoff.md` | New |
| `quality_reports/plans/2026-06-15_workflow-customization.md` | Copy of this plan with status APPROVED on user signoff |

**Not touched:** `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`, `.claude/scripts/`, `.claude/settings.json`, `templates/`, `Preambles/header.tex`, `.githooks/`. Skill internals stay clean for upstream merges.

---

## Explicitly Deferred (next-session candidates)

- **Real paper slugs.** Rename `paper{1,2,3}_TODO` once working titles firm up. Trivial mass-rename.
- **`.claude/agents/domain-reviewer.md` customization** for political-science / IR review lenses (the template ships generic).
- **Journal profile** (`.claude/references/journal-profiles.md`) — add target poli-sci / IR journals (AJPS, APSR, JoP, ISQ, World Politics, IO, etc.) once a target is picked, to calibrate `/review-paper --peer`.
- **ggplot2 theme + palette** for paper figures — defer until first figure work; one consistent theme across all three papers.
- **Bibliography import** from Zotero / Mendeley / existing .bib — user-driven action.
- **Pre-registration** if any paper has a confirmatory design — `/preregister` when the paper is ready.

---

## Verification (post-implementation)

1. `git status` — review the diff; confirm no skill/rule/agent files touched.
2. Grep for residual template placeholders (see Phase 4.1).
3. Open `CLAUDE.md` — read top to bottom; should describe a dissertation, not a lecture template.
4. Compile `Papers/paper1_TODO/manuscript.tex` end-to-end (3-pass XeLaTeX).
5. Confirm `MEMORY.md` reads as the user's project memory.
6. Confirm session log is on disk.
7. Report back: what changed, what's deferred, what the user should look at first.
