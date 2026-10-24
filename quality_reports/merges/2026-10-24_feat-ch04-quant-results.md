# Quality Report: Merge to Main -- 2026-10-24

**PR:** [#3](https://github.com/HasaanParker/claude-code-my-workflow/pull/3) · **Branch:** `feat/ch04-quant-results` · **Merge commit:** `7f8699c`

## Summary

Merged the quantitative core of Chapter 4: a corrected inference regime
(explicit `vcov = ~iso3c` replacing a false "fixest default" clustering claim),
a 2000–2021 estimation window matched to GCDF 3.0 coverage, an
alignment-based re-operationalization of sphere-of-influence, and two new
analysis pipelines (`03_iv_robustness`, `04_var_dynamics`). Chapter 4 moves
from five placeholder sections to a drafted chapter wired to the scripts by 12
`%% source:` markers.

## Files Modified

| File | Type | Quality Score |
|------|------|---|
| `Dissertation/manuscript.tex` | Paper | 100/100 |
| `Dissertation/chapters/ch04_quant_main.tex` | Paper | 100/100 |
| `Dissertation/chapters/ch03_theory.tex` | Paper | — (SOI measure only) |
| `Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R` | Code | 100/100 |
| `Dissertation/analyses/03_iv_robustness/scripts/R/00_run_all.R` | Code | 100/100 |
| `Dissertation/analyses/04_var_dynamics/scripts/R/00_run_all.R` | Code | 100/100 |
| `Dissertation/analyses/01_quant_main/scripts/R/02_clean.R` | Code | 70/100 (false positive — see Notes) |
| `Dissertation/analyses/03_iv_robustness/scripts/R/03_analyze.R` | Code | 10/100 (false positive — see Notes) |
| `Dissertation/analyses/04_var_dynamics/scripts/R/03_analyze.R` | Code | 40/100 (false positive — see Notes) |
| `Dissertation/tables/table_{main,controls,soi,soi_controls,soi_trends,iv,var}.tex` | Generated | — |
| `Dissertation/figures/fig_{coef_by_region,coef_by_soi,irf,iv_first_stage}.pdf` | Generated | — |
| `CLAUDE.md`, `Dissertation/README.md`, 3 analysis READMEs, `MEMORY.md` | Docs | — |
| 7 × `quality_reports/session_logs/*.md` | Docs | — |

## Verification

- [x] Compilation/execution succeeds — full 3-pass XeLaTeX + bibtex on merged
      `main`: **24 pp**, exit 0, 0 errors, no unresolved rerun warnings; one
      0.107pt sub-pixel overfull box (known, left alone). All three pipelines
      run end-to-end via `00_run_all.R`.

      > The commit message on `7b143f5` and PR #3 initially said 23 pp. That
      > came from a single XeLaTeX pass against stale `.aux` files; the stable
      > count after the full bibtex + 3-pass cycle is 24. Corrected here and in
      > the PR body. No conclusion depends on it.
- [x] Tolerance checks PASS (if applicable) — every numeric claim in Ch 4
      traces to a script via `%% source:`; tables are `\input{}` from generated
      fragments rather than transcribed.
- [ ] Tests pass (if applicable) — N/A, no test suite for analysis scripts.
- [x] Quality gates >= 80 — on all paper surfaces and all three pipeline
      orchestrators. Three analysis scripts score below 80 on verified checker
      false positives; see Notes.

Additional gates run manually (the pre-commit hook is **not** installed in this
clone — `core.hooksPath` is unset):

- `./scripts/check-surface-sync.sh` — passes (22 count assertions, skill
  integrity, model-version currency).
- `./scripts/validate-setup.sh` — exits 1 on one pre-existing item only: Quarto
  not installed. `Slides/`/`Quarto/` are dormant per CLAUDE.md and this branch
  touches neither.

## Status

MERGED

## Notes

### Quality-gate deviation (deliberate, verified)

Three R scripts score 10–70/100. Each finding was checked against
`scripts/quality_score.py` source rather than assumed:

- `check_hardcoded_paths` matches `["\'][/\\]` — a quote followed by `/` or
  `\`. It fires on `message("\n...` (an escaped newline) and on the comment
  `"US-aligned"/"Contested"`. Neither is a path.
- `has_random` is a substring test for `sample`, which matches *prose* ("the IV
  sample is 2000–2015"). The real seed is `set.seed(PROJECT_SEED)` once per
  pipeline in `00_run_all.R`, per the seed-once invariant; the scorer reads
  files in isolation and cannot see it.

Neither the shared scorer nor the R code was changed: modifying template
infrastructure was outside this branch's scope, and contorting analysis code to
dodge a regex would make it worse. **Follow-up candidate:** tighten the path
regex to require a path-like continuation, and make the seed check
pipeline-aware rather than file-local.

### Substantive caveats carried into main

1. **The headline result is specification-fragile.** Pooled effect 0.053
   (p=.007) without country-specific trends; −0.002 (p=.900) with them. This
   specification call decides whether there is a finding at all and is an
   advisor-level decision, documented in the chapter body rather than an
   appendix. **Open.**
2. **No cut recovers H1's predicted sign.** The only robust positive effect
   sits in *US-aligned* recipients (0.071–0.082), not the contested ones H1 is
   about. The "reinforcement" reading is stated as a candidate interpretation,
   explicitly not a claim. The prospectus's +0.113 Africa finding never
   reproduced on GCDF 3.0.
3. **The IV has no first stage** under the only predetermined share definition
   (F=0.27), and reduces to `share_i × trend_t`, so it cannot address the
   differential-trending confound it was meant to remedy. Kept as a negative
   result on a correctly-built instrument (two fidelity bugs against the
   published do-file were fixed first).

### Follow-ups

- Ch 4's final `\section{Robustness}` is still a placeholder; leave-one-out and
  alternative clustering ended up inside the SOI and IV sections, so it needs
  **rescoping** rather than filling in as written.
- `02_h2_private_goods` (H2 delivery channels) not started; independent of the
  trend fragility.
- `05_advisor_reframe` predict-and-compare still parked, but its
  pre-China-baseline machinery now exists.
- `./scripts/install-hooks.sh` has not been run in this clone, so gates rely on
  being invoked manually. Worth activating.
