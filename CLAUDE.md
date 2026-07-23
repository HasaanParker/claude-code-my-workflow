# CLAUDE.MD — Foreign Aid Competition: US–China (Dissertation)

**Project:** Foreign Aid Competition: US–China *(working title — refine when papers' framing firms up)*
**Field:** Political Science / International Relations
**Institution:** * University of Wisconsin-Madison 
**Format:** Hybrid dissertation — ~3 related papers, between traditional book-style and pure 3-paper.
**Toolchain:** R (Positron) for analysis · LaTeX/XeLaTeX for writing · PDF as the canonical artifact.
**Branch:** main

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/YYYY-MM-DD_*.md`.
- **Contractor mode** — once a plan is approved, coordinate autonomously; surface only for ambiguity or real decisions.
- **Verify after** — compile/render and confirm output at the end of every task.
- **Single source of truth** — each paper's `manuscript.tex` is authoritative; tables and numbers in it must trace back to scripts via `\input{tables/...}` / `%% source: scripts/R/...` comments.
- **Publication-ready visuals** — figures and tables are polished by default; no draft-quality intermediates.
- **Cross-artifact review is central** — `/review-paper` auto-invokes `/review-r` + `/audit-reproducibility` over the dependency graph.
- **Quality gates** — nothing ships below 80/100.
- **[LEARN] tags** — when corrected, append `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md).

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
my-project/
├── CLAUDE.MD                              # This file
├── MEMORY.md                              # Working memory + [LEARN] entries
├── README.md                              # Project-facing readme
├── Bibliography_base.bib                  # Shared bibliography (all 3 papers cite from here)
├── Papers/                                # Dissertation papers (primary work)
│   ├── README.md
│   ├── paper1_TODO/
│   │   ├── manuscript.tex                 # the paper itself; \input{../../Preambles/header.tex}
│   │   ├── scripts/R/                     # 00_run_all.R + 01_load → 05_figures.R
│   │   ├── _outputs/                      # R intermediate .rds (gitignored except .gitkeep)
│   │   ├── figures/                       # PDF figures sourced into manuscript
│   │   ├── tables/                        # LaTeX table fragments (\input{})
│   │   └── README.md                      # paper-level overview
│   ├── paper2_TODO/                       # same shape
│   └── paper3_TODO/                       # same shape
├── Preambles/header.tex                   # Shared LaTeX preamble (palette, packages)
├── Slides/                                # Job talks / conference decks (dormant unless invoked)
├── Quarto/                                # RevealJS mirror infra (dormant)
├── docs/                                  # GitHub Pages target (dormant)
├── scripts/                               # Repo-wide tooling (quality_score.py, validate-setup.sh, etc.)
├── quality_reports/
│   ├── plans/                             # Approved plans on disk
│   ├── specs/                             # Requirements specs (for ambiguous tasks)
│   ├── session_logs/                      # Session-by-session notes
│   ├── archive/                           # Upstream template artifacts kept for reference
│   ├── merges/                            # Quality reports at merge time
│   └── decisions/                         # Decision records
├── explorations/                          # Research sandbox (60/100 threshold, see exploration rules)
├── templates/                             # Session log, spec, quality-report, passport templates
└── master_supporting_docs/                # Reference papers, source materials
```

---

## Commands

```bash
# Compile a paper (3-pass XeLaTeX from inside the paper directory)
cd Papers/paper1_TODO && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex && \
  BIBINPUTS=../..:$BIBINPUTS bibtex manuscript && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex

# Run a paper's analysis end-to-end
cd Papers/paper1_TODO && Rscript scripts/R/00_run_all.R

# Quality score (works on .tex or .qmd)
python scripts/quality_score.py Papers/paper1_TODO/manuscript.tex
```

---

## Quality Thresholds (advisory)

| Score | Checkpoint | Meaning |
|-------|------------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR / share | Ready for advisor / coauthor |
| 95 | Excellence | Submission-ready |

Enforced by `/commit` (halts + asks for override) and — once you run `./scripts/install-hooks.sh` — by `.githooks/pre-commit` (surface-sync + ≥80 gates on every commit). Bypass sparingly with `SKIP_QUALITY_GATE=1` or `--no-verify`.

---

## Primary Workflows

**Empirical (R analysis, identification, reproducibility):**
`/data-analysis` `/did-event-study` `/diagnose` `/audit-reproducibility` `/replication-package` `/capture-environment` `/power-analysis` `/disclosure-check` `/simulation-study` `/review-r`

**Research / writing:**
`/lit-review` `/research-ideation` `/interview-me` `/preregister`

**Paper review + revision:**
`/review-paper` (incl. `--peer` and `--variance N`) `/seven-pass-review` `/verify-claims` `/proofread` `/humanize` `/respond-to-referees` `/submission-disclosures`

**Meta / workflow:**
`/commit` `/learn` `/checkpoint` `/context-status` `/compress-session` `/promote-memory` `/deep-audit`

**Dormant (talks / lectures only — invoke when prepping a job talk or conference deck):**
`/create-lecture` `/qa-quarto` `/translate-to-quarto` `/slide-excellence` `/pedagogy-review` `/respond-to-eval` `/syllabus` `/scaffold-exercises` `/deploy` `/extract-tikz` `/new-diagram`

The full skills table lives in [README.md](README.md).

---

## Paper Progress

| Slug | Stage | Manuscript | Lead R script |
|------|-------|------------|---------------|
| paper1_TODO | scaffold | `Papers/paper1_TODO/manuscript.tex` | `Papers/paper1_TODO/scripts/R/00_run_all.R` |
| paper2_TODO | scaffold | `Papers/paper2_TODO/manuscript.tex` | `Papers/paper2_TODO/scripts/R/00_run_all.R` |
| paper3_TODO | scaffold | `Papers/paper3_TODO/manuscript.tex` | `Papers/paper3_TODO/scripts/R/00_run_all.R` |

*Rename `_TODO` slugs to real working titles once they firm up — mass `git mv` + grep-replace in this table.*

---

## Slides infrastructure (dormant)

`Slides/`, `Quarto/`, `Preambles/header.tex`, the palette-sync scripts, and the `Slides`-oriented skills are kept for future **job-talk and conference deck** work. They are not used in day-to-day dissertation work. When the first talk is prepared, document any new Beamer environments or Quarto CSS classes here.

---

## Deferred customizations (next-session candidates)

- Rename `Papers/paper{1,2,3}_TODO/` once working titles firm up.
- Customize `.claude/agents/domain-reviewer.md` for political-science / IR review lenses (template ships generic).
- Add target poli-sci / IR journals to `.claude/references/journal-profiles.md` (AJPS, APSR, JoP, ISQ, World Politics, IO, etc.) once a journal is targeted, to calibrate `/review-paper --peer`.
- Pick a single ggplot2 theme + color palette for paper figures once the first figure is built.
- Import bibliography from Zotero / existing `.bib` into `Bibliography_base.bib`.
