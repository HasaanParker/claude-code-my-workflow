# Session Log: 2026-08-06 — First analytical piece (/data-analysis, quant main)

**Status:** IN PROGRESS — **paused for the Dec 2024 prospectus** (baseline recipe)

## Objective

Execute `quality_reports/specs/2026-06-15_first-analysis-quant-refresh.md` against
the data loaded into `Dissertation/data/`. Analysis lives in
`Dissertation/analyses/01_quant_main/` (scripts/R skeleton + `_outputs/` via `.here`).

## Data inspected (Pre-Flight)

- `us_oda_commits_70_22.csv` — OECD DAC3A, USA ODA **commitments**, recipient×year,
  **1970–2022**, `OBS_VALUE` constant-2022 USD millions. 233 "recipients" incl.
  aggregates → filter to ISO-3 countries (drop `5*`/`A7_X` codes).
- `chinadevefinance_3_0.xlsx` (sheet `GCDF_3.0`) — AidData GCDF 3.0, 20,985
  project rows, **Commitment Year 2000–2021**. `Flow Class` = ODA-like 14,224 /
  OOF-like 5,517 / Vague 1,244. `Recommended For Aggregates` Yes 17,957.
  `Amount (Constant USD 2021)` right-skewed (→logs), 8,186 NA amounts.
- Join: both carry ISO-3; `countrycode` installed; overlap window **2000–2021**.
- Packages: all present except **`panelvar`** (needed for VAR — install when unpaused).

## Decisions (AskUserQuestion, 2026-08-06)

| Question | Decision |
|---|---|
| China flow measure | **Both, side by side** — (a) ODA-like only, (b) ODA-like + OOF-like — carried as parallel specs through EDA, correlation, FE, VAR. |
| +0.113 baseline reproduction | **User will provide the Dec 2024 prospectus / Appendix Table 1 (or replication code)** into `master_supporting_docs/` so I match the exact construction. **Blocking.** |
| Run scope | **Full pipeline incl. VAR** — clean → EDA → region correlation → country+year FE → panel VAR/Granger. |

## Blocker

`master_supporting_docs/` is empty → cannot faithfully reproduce +0.113 without the
prospectus recipe (unit, transform, flow class, sample, matching, deflator).
Per the user's choice, **paused** until the prospectus is provided.

## Next steps (on unpause)

1. Read the prospectus/appendix; extract the exact baseline construction.
2. `panelvar` install; then 01_load → 02_clean (both China measures, ISO-3×year
   panel, region from ISO-3) → EDA → 03 correlation (match recipe) + FE model →
   04 tables → 05 figures (define the project ggplot theme — first figure) → VAR.
3. r-reviewer on the scripts; wire tables/figures into `chapters/ch04_quant_main.tex`.

## Reproduction finding (2026-08-06) — +0.113 does NOT reproduce on current data

User provided their working script (`.../Scripts/us china aid .R`) as the recipe.
Faithfully reimplemented it in 01_load→03_analyze. Panel: 7,950 rows, 150 US-recipient
countries, 1970–2022, both China measures.

**Core FE model** `feols(log(us_aid+1) ~ log(china_*_lag+1) | Year + iso3c)`, coef on
the China term (country-clustered SE):

| Region | china_all | china_oda |
|---|---|---|
| Pooled | +0.087*** | +0.058*** |
| Africa | **+0.048** (p.004) | +0.005 (ns) |
| Americas | +0.082*** | +0.052* |
| Asia | +0.004 (ns) | +0.048 |
| Europe | +0.493*** | +0.441*** |
| Oceania | +0.141** | +0.006 (ns) |

**Discrepancy:** prospectus target is +0.113 in Africa with NEGATIVE correlations
elsewhere. Neither reproduces here: the FE elasticity is +0.048 in Africa and mostly
POSITIVE elsewhere; a sweep of standard correlation definitions gives Africa +0.20..+0.35
(all positive). The value 0.113 matches the POOLED country-level correlation (0.114), not
Africa's. **Did not tune to force a match** (anti-p-hacking; replication-protocol).

**Leading hypotheses:** (1) data vintage — prospectus likely GCDF **2.0** (2000–2017) vs
our **3.0** (2000–2021); (2) US input — script shows `usa oda commits.csv` was "switched
with" the `_70_22` file, prospectus may have used the former (not in repo); (3) construction
(per-capita / disbursements / correlation sample).

**Status:** baseline reproduction BLOCKED on identifying the prospectus's exact vintage +
inputs. Escalated to user (AskUserQuestion). Direction of the Africa effect (positive =
aid race) does reproduce; the exact +0.113 magnitude does not.

## Optional groundwork offered (prospectus-independent)

Load + harmonize + EDA + install panelvar can run now without the prospectus;
offered to the user pending their go-ahead.
