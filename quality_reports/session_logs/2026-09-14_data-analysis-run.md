# Session Log: 2026-09-14 — First analytical piece, full run (/data-analysis)

**Status:** COMPLETED (pipeline verified end-to-end, r-reviewer findings incorporated; pending user review of the two empirical discrepancies below)

## Objective

Resume the 2026-08-06 `/data-analysis` session (paused for the prospectus recipe,
then unblocked when the user provided their working script and, per MEMORY.md,
decided to proceed on the current data vintage). This session: merge the
WDI controls the user fetched, extend the short-run FE model, add the panel VAR
(spec MUST item, previously deferred), wire tables/figures into
`chapters/ch04_quant_main.tex`, and run everything end-to-end.

## Changes Made

| File(s) | Change | Reason |
|---|---|---|
| `Dissertation/analyses/01_quant_main/scripts/R/01_load.R` | + optional `raw_wdi` read (NULL-safe if cache missing) | WDI controls now available (`Dissertation/data/wdi_controls.rds`, user-fetched) |
| `.../02_clean.R` | + SOI ingredient (UNGA ideal-point distance from US, corrected session→year mapping) + WDI merge + `panel.rds` persistence | Extended spec coverage; cross-analysis reuse for the VAR |
| `.../03_analyze.R` | + EDA diagnostics section; + controls-augmented FE spec alongside baseline | Data-analysis skill Phase 2; SHOULD-item sensitivity check |
| `.../04_tables.R`, `.../05_figures.R` | Rewritten for the actual region×measure results; `theme_dissertation()` defined (resolves CLAUDE.md deferred item); dual-write to `_outputs/` + `Dissertation/{tables,figures}/`; runtime cairo probe (see Learnings) | Real, committed publication output, not stub content |
| `Dissertation/analyses/04_var_dynamics/scripts/R/*` (new, all 6 files) | Full pipeline: reuse `01_quant_main`'s panel, restrict to 2000–2021, bivariate panel VAR via `panelvar::pvargmm` (system GMM), IRFs + bootstrap CI + stability check, table + figure | Spec MUST item, previously deferred pending data |
| `Dissertation/chapters/ch04_quant_main.tex` | Data/Strategy/Results/VAR sections drafted with real numbers (was all-placeholder) | Real results now exist to report |
| `Dissertation/README.md`, `CLAUDE.md`, `analyses/04_var_dynamics/README.md`, `analyses/01_quant_main/scripts/R/README.md` | Status tables updated; fixed a pre-existing `here("..","..","..",...)` off-by-one in the README's documented path (should be 2 levels, not 3) | Reflect actual run status; doc/code parity |
| `MEMORY.md`, `.claude/state/personal-memory.md` (gitignored) | `[LEARN]` entries: VAR finding, and the R 4.4→4.6 package-loss / `capabilities("cairo")` false-positive | Project fact + portable workflow lesson vs. machine-specific fact, split per meta-governance.md |

## Design Decisions

| Decision | Alternatives | Rationale |
|---|---|---|
| Panel VAR window = 2000–2021 only | Full 1970–2022 with structural pre-2000 China zeros | Pre-2000 zeros are a coverage artifact (GCDF starts 2000), not real absence of Chinese finance; including them would treat an artifact as a dynamic |
| VAR on `china_all` only (not `china_oda` too) | Run both measures as in the FE model | GMM + 200-draw bootstrap is expensive (~9 min); scoped as a documented, disclosed extension rather than doubling runtime for this pass |
| `collapse = TRUE` in `pvargmm` | Uncollapsed GMM instruments | T=22 is long enough that uncollapsed instruments would proliferate toward Roodman's "too many instruments" problem |
| Report the Hansen-J rejection prominently (table footer + chapter prose + README) | Note it quietly / omit | Anti-p-hacking / replication-protocol discipline already established this project — a load-bearing caveat, not footnote trivia |
| `theme_dissertation()` defined once in `01_quant_main/05_figures.R`, duplicated (not shared-file) into `04_var_dynamics/05_figures.R` | A shared `theme.R` util sourced by both | Each analysis's fixed 5-script pipeline stays self-contained; duplication is ~15 lines, documented with a cross-reference comment |
| Runtime cairo probe instead of trusting `capabilities("cairo")` | Trust the capability flag as before | The flag lied on this machine post-R-upgrade (see Learnings) — caught because the figure silently didn't write on the first run |

## Verification Results

| Check | Result | Status |
|---|---|---|
| `Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R` | Full pipeline runs clean, all outputs listed | PASS |
| `Dissertation/analyses/04_var_dynamics/scripts/R/00_run_all.R` | Full pipeline runs clean (after the `se()` dimnames fix — see below) | PASS |
| `Dissertation/tables/`, `Dissertation/figures/` populated | `table_main.tex`, `table_controls.tex`, `table_var.tex`, `fig_coef_by_region.pdf`, `fig_irf.pdf` all present | PASS |
| Manuscript compiles (XeLaTeX ×2) with real `\input`s | Exit 0, 17 pages, no undefined refs, no overfull hboxes | PASS |
| `quality_score.py` on `manuscript.tex` + `ch04_quant_main.tex` | 100/100 both | PASS |
| Panel VAR stability | Eigenvalues 0.48, 0.22 — inside unit circle | PASS |
| Panel VAR Hansen-J test | $\chi^2(28)=100.22$, $p<.001$ — **rejects** | **CAVEAT, not a hard failure — flagged everywhere** |
| r-reviewer on all changed R scripts | Delegated (async); findings pending | IN PROGRESS |

## A bug caught and fixed mid-session

`04_tables.R` (both analyses) initially used `here("..", "..", "..", "tables")`
(3 levels up) to reach `Dissertation/tables/` from `analyses/NN/` — actually 2
levels (`analyses/` → `Dissertation/`). This silently wrote to the repo root
instead of `Dissertation/tables/` on the first run (caught by checking the
target directory after running, not by an error — `here()` doesn't fail on a
nonexistent-but-constructible path). Fixed in both scripts and in the
`scripts/R/README.md` doc that had the same 3-level mistake.

## Learnings & Corrections

- [LEARN:workflow] (MEMORY.md) Pre-Flight package checks are a snapshot; verify again after any session gap, especially across a tool-version bump.
- [LEARN:r-env] (`.claude/state/personal-memory.md`, gitignored) R 4.4→4.6 upgrade on this Mac wiped `fixest`/`plm`/`janitor`; `capabilities("cairo")` misreports post-upgrade.
- [LEARN:data] (MEMORY.md) VAR finds no significant lagged cross-donor effect; Hansen-J rejects — see above.

## r-reviewer findings + fixes applied

Delegated to `r-reviewer` on all 13 changed/new R scripts. Findings:

- **Critical (fixed):** `03_analyze.R`'s docstring claimed SEs were "clustered
  by country (fixest default: first FE)". Verified independently:
  `feols()`'s true no-argument default with two FEs is **plain IID**, not
  clustering at all. Fixed with explicit `vcov = ~iso3c` in both `fit_cell()`
  and `fit_cell_ext()`. **This changed which regions are significant** —
  see the MEMORY.md `[LEARN:data]` entry; point estimates unchanged, several
  p-values did. Chapter text rewritten to match; full pipeline re-run.
- **Major (fixed):** extended spec mixed lagged treatment with contemporaneous
  `gdppc`/`pop` controls — now `gdppc_lag`/`pop_lag`, added in `02_clean.R`.
- **Major (fixed):** extended spec had no NULL-safety if `wdi_controls.rds`
  were missing (would crash deep in the fit loop) — now gated on
  `has_wdi_controls`, skips loudly with a warning if absent.
- **Minor, not addressed:** duplicated `PROJECT_SEED` literal across
  `00_run_all.R` files (matches this project's own documented per-analysis
  seed convention, not a defect); console-message verbosity in `03_analyze.R`;
  `fetch_wdi.R` pulls WDI aggregates (`country="all"`) that never match a
  panel ISO-3 (harmless); `log_china_oda` computed but unused in the VAR
  (documented future extension).

**quality_score.py false positives (pre-existing, not introduced this
session):** `03_analyze.R` scores 30/100 BLOCKED on 2 checker bugs, both
confirmed by reading the checker's own source — (1) `"\n` at the start of a
`message()` string literal matches the "hardcoded absolute path" regex
(`["\'][/\\]`, which doesn't distinguish an escape sequence from a path);
(2) the substring `"sample"` in prose ("estimation sample") trips the
"missing set.seed()" check, which does a literal substring search for RNG
function names and doesn't know this project seeds once in the orchestrator
(INV-9, documented in `scripts/R/README.md`). Matches the exact false-positive
class the original restructure plan anticipated ("the same 04_tables.R false
positive we saw last commit"). Not fixed — `scripts/quality_score.py` is
shared repo-wide tooling, out of scope for a data-analysis session without
being asked.

## Open Questions / Blockers

- [ ] **Two empirical discrepancies need the user's read, not just code fixes:**
  1. The short-run FE elasticity is positive almost everywhere, not Africa-specific — H1's "negative outside Africa" half doesn't hold on this data vintage.
  2. The panel VAR finds no significant lagged relationship in either direction, and its overidentification test rejects.
  Both are reported honestly in `ch04_quant_main.tex` with explicit "not yet adjudicated" framing. This is a discussion for the user (and likely the advisor), not something further code iteration resolves on its own.
- [ ] `china_oda`-only panel VAR not run (documented, scoped-out extension).
- [ ] XQuartz not installed — figures use the base `pdf()` device (functionally fine, slightly plainer fonts/AA) until it's installed.
- [ ] IV robustness (`03_iv_robustness/`) still needs the Dreher/Zeitz steel-production data — not in `Dissertation/data/`.

## Next Steps

- [ ] User decision: how to read/frame the two discrepancies above in the theory chapter and results narrative.
- [ ] Robustness section (Ch 4 §4.5 — spec curve, leave-one-out, alternative clustering) still placeholder.
- [ ] `/commit` once the above is resolved.
