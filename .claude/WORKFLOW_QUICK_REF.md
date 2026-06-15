# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)
**Project:** Foreign Aid Competition: US–China dissertation

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"
- **First ~5 sessions:** lean toward extra check-ins so you can calibrate the workflow.

---

## I Just Execute When

- Code fix is obvious (bug, pattern application).
- Verification (tolerance checks, tests, compilation).
- Documentation (logs, commits).
- Plotting per the established standards below.
- Deployment (after you approve, I ship automatically).

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| ≥ 80 | Ready to commit |
| 80–90 | Ready to share with advisor / coauthor |
| ≥ 95 | Submission-ready |
| < 80 | Fix blocking issues |

---

## Non-Negotiables (this project)

- **R paths:** always `here::here("...")`. Never hardcoded absolute paths. Never `setwd()`.
- **R seeds:** one `set.seed(20260615)` (or paper-level seed) at the top of `01_load.R` for the paper. Never inline mid-script.
- **R workflow:** numbered scripts `00_run_all.R` → `01_load.R` → `02_clean.R` → `03_analyze.R` → `04_tables.R` → `05_figures.R`. Intermediate outputs to `_outputs/*.rds`.
- **Figures:** vector PDF for manuscript inclusion (`ggsave(..., device = cairo_pdf)`); ≥300 DPI PNG only when raster is unavoidable; white background; one consistent `ggplot2` theme across all three papers (theme TBD on first figure — once chosen, lock it in).
- **Tables:** `gt` or `kableExtra` → LaTeX fragment via `\input{tables/<name>.tex}`. No manual copy-paste of numbers from R console into TeX.
- **Bibliography:** all citations come from root `Bibliography_base.bib`. Do not let a paper fork its own bib file.
- **Tolerance:** 1e-6 default for point-estimate reproducibility checks; near-misses within 1e-4 flagged for manual review, not auto-passed.
- **Compilation:** XeLaTeX only, 3-pass, with `TEXINPUTS=../../Preambles:$TEXINPUTS` from inside the paper directory.

---

## Preferences

- **Visuals:** publication-ready by default — no draft-quality intermediates. If a figure won't be polished, say so explicitly before producing it.
- **Reporting:** concise bullets; surface details on request.
- **Session logs:** always (post-plan, incremental, end-of-session) → `quality_reports/session_logs/YYYY-MM-DD_*.md`.
- **Replication:** strict; near-misses are flagged, not silently accepted.
- **Memory:** when corrected, save `[LEARN:category]` to [MEMORY.md](../MEMORY.md) immediately. Don't make the same mistake twice.

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/`.
- 60/100 quality threshold (vs. 80/100 for production).
- No plan needed — just a research value check (2 min).
- See `.claude/rules/exploration-fast-track.md`.

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
