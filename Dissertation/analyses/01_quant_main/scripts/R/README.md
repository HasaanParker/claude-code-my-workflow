# `Dissertation/analyses/01_quant_main/scripts/R/` — main quantitative pipeline

Numbered scripts for the dissertation's core short-run allocation analysis
(Chapter 4). Run via `00_run_all.R`; never source mid-pipeline scripts
individually unless debugging.

## Conventions (this project)

- **Paths** via `here::here()`. A `.here` sentinel file in
  `Dissertation/analyses/01_quant_main/` makes `here()` resolve to this analysis
  root — so `here("_outputs")` writes to
  `Dissertation/analyses/01_quant_main/_outputs/` regardless of where you run R
  from. Never `setwd()`. Cross-cutting data lives under `Dissertation/data/`
  (reached with `here("..", "..", "data")` — two levels up: `analyses/`, then
  `Dissertation/`).
- **Seed** set once in `00_run_all.R` (`PROJECT_SEED <- 20260615L`). Stochastic
  scripts re-seed locally from `PROJECT_SEED` so direct debugging runs are still
  deterministic. Change only with a recorded reason in the session log (per
  `INV-9`).
- **`sessionInfo()`** written to `_outputs/sessionInfo.txt` at the end of
  `00_run_all.R` so reviewers can verify the environment.
- **Outputs** to `_outputs/` (RDS for fitted models / intermediate data),
  `Dissertation/tables/` (LaTeX fragments via `\input`), `Dissertation/figures/`
  (PDF via `cairo_pdf` device).
- **Numerical discipline** per `.claude/rules/r-code-conventions.md` §8: no float
  equality, CDF clamping with epsilon, integer literals for counts, pre-allocated
  vectors.
- **Inference robustness** per `.claude/rules/inference-robustness.md`:
  family-wise / FDR correction when applicable, specification curve /
  leave-one-out, alternative clustering.
- **Replication** per `.claude/rules/replication-protocol.md`: when replicating
  prior work, hit the targets to the dot before extending.

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
cd Dissertation/analyses/01_quant_main && Rscript scripts/R/00_run_all.R
```

Expected outputs:

| File | Condition |
|---|---|
| `_outputs/results.rds` | Always |
| `_outputs/sessionInfo.txt` | Always |
| `_outputs/diagnostics/*.pdf` | Always (EDA; gitignored, not wired into the manuscript) |
| `_outputs/table_main.tex`, `_outputs/table_controls.tex` | Always |
| `_outputs/fig_coef_by_region.pdf` | Always |

`04_tables.R` / `05_figures.R` write each finished table/figure to **two**
places: the gitignored `_outputs/` copy (the pipeline-contract artifact
`/audit-reproducibility` and re-run diffing use) and the committed
`Dissertation/tables/` / `Dissertation/figures/` copy that
`chapters/ch04_quant_main.tex` actually `\input{}`s / `\includegraphics{}`s.
Both are written via `here("..", "..", "tables")` / `here("..", "..", "figures")`
— two levels up from `analyses/01_quant_main/` to `Dissertation/`.

## Starting a sibling analysis (02–05)

The other `analyses/NN_*/` folders have a `.here` sentinel and a README but no
script skeleton yet. To start one, copy this directory:

```bash
cp -R scripts ../02_h2_private_goods/scripts   # from analyses/01_quant_main/
```

## Reviewing

- `/review-r Dissertation/analyses/01_quant_main/scripts/R/03_analyze.R` — R code-review agent.
- `/audit-reproducibility Dissertation/manuscript.tex` — verifies fixed seeds, no
  absolute paths, sessionInfo capture, and that `00_run_all.R` regenerates all
  outputs the manuscript's chapters depend on.
