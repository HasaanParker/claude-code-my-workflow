# `Papers/paper3_TODO/scripts/R/` — Paper 3 analysis pipeline

Numbered scripts for a reproducible analysis of paper 3. Run via `00_run_all.R`; never source mid-pipeline scripts individually unless debugging.

## Conventions (this project)

- **Paths** via `here::here()`. A `.here` sentinel file in `Papers/paper3_TODO/` makes `here()` resolve to the paper root — so `here("_outputs")` writes to `Papers/paper3_TODO/_outputs/` regardless of where you run R from. Never `setwd()`.
- **Seed** set once in `00_run_all.R` (`PROJECT_SEED <- 20260615L`). Stochastic scripts re-seed locally from `PROJECT_SEED` so direct debugging runs are still deterministic. Change only with a recorded reason in the session log (per `INV-9`).
- **`sessionInfo()`** written to `_outputs/sessionInfo.txt` at the end of `00_run_all.R` so reviewers can verify the environment.
- **Outputs** to `_outputs/` (RDS for fitted models / intermediate data), `tables/` (LaTeX fragments via `\input`), `figures/` (PDF via `cairo_pdf` device).
- **Numerical discipline** per `.claude/rules/r-code-conventions.md` §8: no float equality, CDF clamping with epsilon, integer literals for counts, pre-allocated vectors.
- **Inference robustness** per `.claude/rules/inference-robustness.md`: family-wise / FDR correction when applicable, specification curve / leave-one-out, alternative clustering.
- **Replication** per `.claude/rules/replication-protocol.md`: when replicating prior work, hit the targets to the dot before extending.

## Files

| Script | Responsibility |
|---|---|
| `00_run_all.R` | Orchestrator. Sources 01–05 in order, writes `sessionInfo()`, prints timing. |
| `01_load.R` | Read raw data into data frames. No transformations. |
| `02_clean.R` | Type coercion, missingness, joins, derived columns. |
| `03_analyze.R` | Regressions, tests, model fits. Save to RDS. |
| `04_tables.R` | Regression tables → LaTeX fragments. |
| `05_figures.R` | `ggplot2` figures → PDF. |

## Running

```bash
cd Papers/paper3_TODO && Rscript scripts/R/00_run_all.R
```

Expected outputs:

| File | Condition |
|---|---|
| `_outputs/results.rds` | Always |
| `_outputs/sessionInfo.txt` | Always |
| `_outputs/fig_main.pdf` | Always (move to `figures/` when wired into the manuscript) |
| `_outputs/table_main.tex` | Always (move to `tables/` when wired into the manuscript) |

The starter `04_tables.R` / `05_figures.R` write to `_outputs/`. When you have a real table/figure to include in `manuscript.tex`, either change the script's destination to `here("tables")` / `here("figures")`, or copy/move on each run.

## Reviewing

- `/review-r Papers/paper3_TODO/scripts/R/03_analyze.R` — R code-review agent.
- `/audit-reproducibility Papers/paper3_TODO/manuscript.tex` — verifies fixed seeds, no absolute paths, sessionInfo capture, and that `00_run_all.R` regenerates all outputs.
