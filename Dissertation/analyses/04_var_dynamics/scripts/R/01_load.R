# =============================================================================
# 01_load.R — Load the harmonized panel built by 01_quant_main.
#
# This analysis reuses 01_quant_main's cleaned panel (panel.rds) rather than
# re-deriving US/China aid harmonization from scratch, to guarantee the VAR
# and the short-run FE model share one source of truth for the raw aid data.
# CROSS-ANALYSIS DEPENDENCY: 01_quant_main/scripts/R/00_run_all.R must have
# been run at least once (panel.rds is gitignored, regenerated each run).
# =============================================================================

suppressPackageStartupMessages(library(here))

panel_path <- normalizePath(
  here::here("..", "01_quant_main", "_outputs", "panel.rds"),
  mustWork = FALSE
)
if (!file.exists(panel_path)) {
  stop(
    "01_load.R: ", panel_path, " not found.\n",
    "Run Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R first ",
    "-- 04_var_dynamics reuses its harmonized panel rather than re-deriving it."
  )
}

raw_panel <- readRDS(panel_path)
message(sprintf("01_load: raw_panel %d x %d (from 01_quant_main/_outputs/panel.rds)",
                nrow(raw_panel), ncol(raw_panel)))
