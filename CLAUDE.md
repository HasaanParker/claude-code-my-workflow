# CLAUDE.MD — Foreign Aid Competition: US–China (Dissertation)

**Project:** Foreign Aid Competition: US–China *(working title — refine when the chapters' framing firms up)*
**Field:** Political Science / International Relations
**Institution:** * University of Wisconsin-Madison 
**Format:** Monograph (single-argument book). `Dissertation/analyses/NN_*/` is a working-style scaffold that maps onto the empirical chapters, not a set of separate papers. (Decided 2026-06-15 — see `quality_reports/decisions/2026-06-15_monograph-drop-cases.md`.)
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
├── Bibliography_base.bib                  # Shared bibliography (the whole monograph cites from here)
├── Dissertation/                          # The monograph (primary work)
│   ├── manuscript.tex                     # top-level assembly; \input{header}, \include{chapters/chNN_*}
│   ├── chapters/                          # ch01_intro → ch05_conclusion (stubs; fill over time)
│   ├── analyses/                          # compartmentalized R work, one dir per empirical piece
│   │   ├── 01_quant_main/                 # Ch 4 core: short-run allocation models
│   │   │   ├── scripts/R/                 # 00_run_all.R + 01_load → 05_figures.R
│   │   │   ├── _outputs/                  # R intermediate .rds (gitignored except .gitkeep)
│   │   │   ├── .here                      # here::here() resolves to this analysis root
│   │   │   └── README.md
│   │   ├── 02_h2_private_goods/           # H2: NGO vs government delivery (stub)
│   │   ├── 03_iv_robustness/              # Dreher/Zeitz steel × exposure IV (stub)
│   │   ├── 04_var_dynamics/               # panel VAR / long-run co-evolution (stub)
│   │   └── 05_advisor_reframe/            # predict-and-compare side deliverable (SPEC.md; parked)
│   ├── figures/                           # finished PDFs \includegraphics'd into chapters
│   ├── tables/                            # LaTeX table fragments (\input{}) into chapters
│   ├── data/                              # raw + interim (gitignored except .gitkeep)
│   ├── .here                              # here() at the Dissertation level
│   └── README.md                          # what's here, compile command, chapter/analysis status
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
# Compile the monograph (3-pass XeLaTeX from inside Dissertation/)
cd Dissertation && \
  TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex && \
  BIBINPUTS=..:$BIBINPUTS bibtex manuscript && \
  TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex && \
  TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex

# Run an analysis end-to-end (each analyses/NN_*/ is self-contained via its .here)
cd Dissertation/analyses/01_quant_main && Rscript scripts/R/00_run_all.R

# Quality score (works on .tex or .qmd)
python scripts/quality_score.py Dissertation/manuscript.tex
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

## Chapter + Analyses Progress

The manuscript is `Dissertation/manuscript.tex`; it `\include`s the chapters below.

| Chapter | File | Stage |
|---------|------|-------|
| 1. Introduction | `Dissertation/chapters/ch01_intro.tex` | stub |
| 2. Related Literature | `Dissertation/chapters/ch02_lit.tex` | stub |
| 3. Theory | `Dissertation/chapters/ch03_theory.tex` | SOI operationalization + H1 drafted; H2 still stub |
| 4. Quantitative core | `Dissertation/chapters/ch04_quant_main.tex` | drafted with real results (region + SOI-bloc cuts, VAR); robustness section still placeholder |
| 5. Conclusion | `Dissertation/chapters/ch05_conclusion.tex` | stub |

| Analysis | Lead R script | Stage |
|----------|---------------|-------|
| 01 short-run allocation (Ch 4) | `Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R` | **run** (2026-09-14) — FE model + controls, region AND alignment-based-SOI cuts; neither recovers H1's predicted sign-flip (not resolved) |
| 02 H2 private vs public goods | *(copy skeleton from 01 when starting)* | not started |
| 03 IV robustness (steel × exposure) | `Dissertation/analyses/03_iv_robustness/scripts/R/00_run_all.R` | **run** (2026-09-15) — **negative result**: no first stage under a predetermined share; see its README |
| 04 long-run dynamics (panel VAR) | `Dissertation/analyses/04_var_dynamics/scripts/R/00_run_all.R` | **run** (2026-09-14) — system GMM; Hansen-J caveat, see its README |
| 05 advisor predict-and-compare reframe | `Dissertation/analyses/05_advisor_reframe/SPEC.md` | spec only (parked) |

---

## Slides infrastructure (dormant)

`Slides/`, `Quarto/`, `Preambles/header.tex`, the palette-sync scripts, and the `Slides`-oriented skills are kept for future **job-talk and conference deck** work. They are not used in day-to-day dissertation work. When the first talk is prepared, document any new Beamer environments or Quarto CSS classes here.

---

## Deferred customizations (next-session candidates)

- Customize `.claude/agents/domain-reviewer.md` for political-science / IR review lenses (template ships generic).
- Add target poli-sci / IR journals to `.claude/references/journal-profiles.md` (AJPS, APSR, JoP, ISQ, World Politics, IO, etc.) once a journal is targeted, to calibrate `/review-paper --peer`.
- Import bibliography from Zotero / existing `.bib` into `Bibliography_base.bib`.

**Resolved (2026-09-14):** ggplot2 theme + palette — `theme_dissertation()` in
`Dissertation/analyses/01_quant_main/scripts/R/05_figures.R`, matched to
`Preambles/header.tex`'s palette (primary-blue/gold, jet, light-bg).
