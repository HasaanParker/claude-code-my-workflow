# Requirements Specification: First analytical piece — quant refresh + VAR extension

**Date:** 2026-06-15
**Status:** APPROVED
**Context:** First analytical piece for the monograph's Chapter 4. Concrete enough to hand to `/data-analysis` in a future session. Parent research spec: `2026-06-15_dissertation-plan-monograph.md`.

---

## Objective

Refresh the main short-run US-aid-allocation model to a defensible standard
(country FE, a shift-share IV, a revised sphere-of-influence measure) **and** add
a long-run dynamics test (panel VAR / Granger-causality), so Chapter 4 can carry
the dissertation's full empirical burden.

---

## Requirements

### MUST Have (Non-Negotiable)

- [ ] **Reproduce the prospectus baseline first.** Recover the +0.113 Africa /
      negative-elsewhere correlation from the Dec 2024 prospectus (Appendix
      Table 1) before changing anything (per `.claude/rules/replication-protocol.md`).
- [ ] **Country + year fixed effects** in the short-run allocation model
      (`analyses/01_quant_main/`).
- [ ] **Region-stratified estimates** (Africa vs. non-Africa at minimum) so the
      sign heterogeneity central to H1 is visible.
- [ ] **IV for Chinese aid** — Dreher/Zeitz-style shift-share (Chinese steel /
      heavy-industry production × recipient baseline exposure), with reported
      first-stage strength (`analyses/03_iv_robustness/`).
- [ ] **Panel VAR / Granger-causality** on US and Chinese aid flows, with
      impulse-response functions (`analyses/04_var_dynamics/`). Drive a canonical
      panel-VAR package — never hand-roll the estimator.
- [ ] **Revised SOI operationalization**, documented, with the old vs. new
      measure compared.
- [ ] **Reproducibility contract:** fixed seed, `here()` paths (no `setwd()`, no
      absolute paths), `sessionInfo()` captured, `00_run_all.R` regenerates every
      output (per `INV-9`/`INV-10` and the R-script conventions).
- [ ] **Publication-ready outputs:** vector-PDF figures, LaTeX table fragments
      `\input` into `chapters/ch04_quant_main.tex`; every number traceable via
      `%% source:` comments.

### SHOULD Have (Preferred)

- [ ] Uniform/simultaneous inference bands on the IRFs, not just pointwise.
- [ ] Specification-curve / leave-one-out-by-region robustness (per
      `.claude/rules/inference-robustness.md`).
- [ ] Alternative clustering (country, and two-way country×year) reported.
- [ ] Sensitivity of results to the SOI operationalization choices.

### MAY Have (Optional, If Time)

- [ ] H2 split (private vs. public goods delivery) wired in as an interaction
      (otherwise deferred to `analyses/02_h2_private_goods/`).
- [ ] A first pass at the advisor's predict-and-compare gap as a robustness
      column (only if the parked SPEC has firmed up).

---

## Clarity Status

| Aspect | Status | Notes |
|--------|--------|-------|
| Estimator for short-run model | CLEAR | Country + year FE panel regression. |
| IV design | ASSUMED | Steel × exposure shift-share; exact instrument construction to be pinned when data lands. |
| SOI operationalization | BLOCKED | Needs the revised measure defined before final estimates; interim = prospectus measure. |
| Panel-VAR package + lag selection | ASSUMED | Canonical package; lag order by information criterion, revisit for stationarity. |
| Data vintage (GCDF / CRS versions) | BLOCKED | User brings the extracts; pin versions in `capture-environment` at run time. |

---

## Success Criteria

- Prospectus baseline reproduced to tolerance before any extension.
- Short-run FE + region split + IV + panel-VAR all run from `00_run_all.R` per
  analysis dir with no manual steps.
- `/audit-reproducibility Dissertation/manuscript.tex` passes on every Ch 4
  number once wired in.
- Figures/tables land in `Dissertation/{figures,tables}/` and compile into the
  manuscript.

---

## Explicitly out of scope

- Loading the real data (a prerequisite the user supplies; this spec is the plan,
  not the run).
- The other analyses (`02` H2, `05` reframe) beyond the optional hooks above.

---

## Approval

[x] Captured from the 2026-06-15 interview; execute in a **separate** future
session via `/data-analysis` once data lands.
